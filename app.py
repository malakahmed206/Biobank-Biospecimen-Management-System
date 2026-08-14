from flask import Flask, render_template, request, redirect, url_for, flash
import db

app = Flask(__name__)
app.secret_key = "biobank-dev-secret-change-in-production"

SEX_VALUES = ["Male", "Female", "Other", "Unknown"]
SAMPLE_STATUS_VALUES = ["Available", "Depleted", "Quarantined", "Disposed"]
REQUEST_STATUS_VALUES = ["Pending", "Approved", "Completed", "Rejected"]


# --------------------------------------------------------------------------
# Dashboard: searchable / filterable sample inventory (bonus criterion:
# "Data viewing and searching")
# --------------------------------------------------------------------------
@app.route("/")
def dashboard():
    search = request.args.get("q", "").strip()
    status = request.args.get("status", "").strip()

    sql = """
        SELECT s.sample_id, d.donor_code, st.type_name, s.collection_date,
               s.status AS sample_status,
               (SELECT COUNT(*) FROM Aliquot a WHERE a.sample_id = s.sample_id) AS aliquot_count,
               (SELECT COALESCE(SUM(a.volume_ml), 0) FROM Aliquot a WHERE a.sample_id = s.sample_id) AS total_volume
        FROM Sample s
        JOIN Donor d ON s.donor_id = d.donor_id
        JOIN SampleType st ON s.sample_type_id = st.sample_type_id
        WHERE 1=1
    """
    params = []
    if search:
        sql += " AND (d.donor_code LIKE ? OR st.type_name LIKE ?)"
        like = f"%{search}%"
        params += [like, like]
    if status:
        sql += " AND s.status = ?"
        params.append(status)
    sql += " ORDER BY s.sample_id"

    rows = db.fetchall(sql, tuple(params))
    stats = {
        "donors": db.fetchone("SELECT COUNT(*) AS n FROM Donor")["n"],
        "samples": db.fetchone("SELECT COUNT(*) AS n FROM Sample")["n"],
        "aliquots": db.fetchone("SELECT COUNT(*) AS n FROM Aliquot")["n"],
        "pending_requests": db.fetchone(
            "SELECT COUNT(*) AS n FROM TestRequest WHERE status = 'Pending'"
        )["n"],
    }
    return render_template(
        "dashboard.html",
        rows=rows, search=search, status=status,
        status_values=SAMPLE_STATUS_VALUES, stats=stats,
    )


# --------------------------------------------------------------------------
# Donors CRUD
# --------------------------------------------------------------------------
@app.route("/donors")
def donors_list():
    search = request.args.get("q", "").strip()
    sql = "SELECT * FROM Donor WHERE 1=1"
    params = []
    if search:
        sql += " AND donor_code LIKE ?"
        params.append(f"%{search}%")
    sql += " ORDER BY donor_id"
    rows = db.fetchall(sql, tuple(params))
    return render_template("donors_list.html", rows=rows, search=search)


def _validate_donor(form):
    errors = []
    donor_code = form.get("donor_code", "").strip()
    dob = form.get("date_of_birth", "").strip()
    sex = form.get("sex", "").strip()
    email = form.get("contact_email", "").strip()

    if not donor_code:
        errors.append("Donor code is required.")
    if not dob:
        errors.append("Date of birth is required.")
    if sex not in SEX_VALUES:
        errors.append("Sex must be one of: " + ", ".join(SEX_VALUES))
    if email and "@" not in email:
        errors.append("Contact email doesn't look valid.")
    return errors, donor_code, dob, sex, email


@app.route("/donors/new", methods=["GET", "POST"])
def donors_new():
    if request.method == "POST":
        errors, donor_code, dob, sex, email = _validate_donor(request.form)
        if errors:
            for e in errors:
                flash(e, "error")
            return render_template("donor_form.html", donor=request.form, sex_values=SEX_VALUES, mode="new")
        try:
            db.execute(
                "INSERT INTO Donor (donor_code, date_of_birth, sex, contact_email, enrollment_date) "
                "VALUES (?, ?, ?, ?, date('now'))",
                (donor_code, dob, sex, email or None),
            )
            flash(f"Donor {donor_code} created.", "success")
            return redirect(url_for("donors_list"))
        except Exception as e:
            flash(f"Could not save donor: {e}", "error")
            return render_template("donor_form.html", donor=request.form, sex_values=SEX_VALUES, mode="new")
    return render_template("donor_form.html", donor={}, sex_values=SEX_VALUES, mode="new")


@app.route("/donors/<int:donor_id>/edit", methods=["GET", "POST"])
def donors_edit(donor_id):
    donor = db.fetchone("SELECT * FROM Donor WHERE donor_id = ?", (donor_id,))
    if not donor:
        flash("Donor not found.", "error")
        return redirect(url_for("donors_list"))

    if request.method == "POST":
        errors, donor_code, dob, sex, email = _validate_donor(request.form)
        if errors:
            for e in errors:
                flash(e, "error")
            merged = dict(donor); merged.update(request.form)
            return render_template("donor_form.html", donor=merged, sex_values=SEX_VALUES, mode="edit")
        try:
            db.execute(
                "UPDATE Donor SET donor_code=?, date_of_birth=?, sex=?, contact_email=? WHERE donor_id=?",
                (donor_code, dob, sex, email or None, donor_id),
            )
            flash(f"Donor {donor_code} updated.", "success")
            return redirect(url_for("donors_list"))
        except Exception as e:
            flash(f"Could not update donor: {e}", "error")

    return render_template("donor_form.html", donor=donor, sex_values=SEX_VALUES, mode="edit")


@app.route("/donors/<int:donor_id>/delete", methods=["POST"])
def donors_delete(donor_id):
    try:
        db.execute("DELETE FROM Donor WHERE donor_id = ?", (donor_id,))
        flash("Donor deleted.", "success")
    except Exception as e:
        flash(f"Could not delete donor (it may have related records): {e}", "error")
    return redirect(url_for("donors_list"))


# --------------------------------------------------------------------------
# Samples CRUD
# --------------------------------------------------------------------------
@app.route("/samples")
def samples_list():
    search = request.args.get("q", "").strip()
    sql = """
        SELECT s.*, d.donor_code, st.type_name
        FROM Sample s
        JOIN Donor d ON s.donor_id = d.donor_id
        JOIN SampleType st ON s.sample_type_id = st.sample_type_id
        WHERE 1=1
    """
    params = []
    if search:
        sql += " AND d.donor_code LIKE ?"
        params.append(f"%{search}%")
    sql += " ORDER BY s.sample_id"
    rows = db.fetchall(sql, tuple(params))
    return render_template("samples_list.html", rows=rows, search=search)


def _lookups():
    donors = db.fetchall("SELECT donor_id, donor_code FROM Donor ORDER BY donor_code")
    types = db.fetchall("SELECT sample_type_id, type_name FROM SampleType ORDER BY type_name")
    events = db.fetchall(
        "SELECT event_id, event_date, location FROM CollectionEvent ORDER BY event_id"
    )
    return donors, types, events


def _validate_sample(form):
    errors = []
    donor_id = form.get("donor_id", "").strip()
    sample_type_id = form.get("sample_type_id", "").strip()
    event_id = form.get("event_id", "").strip()
    collection_date = form.get("collection_date", "").strip()
    volume_ml = form.get("volume_ml", "").strip()
    status = form.get("status", "").strip()

    if not donor_id:
        errors.append("Donor is required.")
    if not sample_type_id:
        errors.append("Sample type is required.")
    if not event_id:
        errors.append("Collection event is required.")
    if not collection_date:
        errors.append("Collection date is required.")
    try:
        vol = float(volume_ml)
        if vol <= 0:
            errors.append("Volume must be greater than zero.")
    except ValueError:
        errors.append("Volume must be a number.")
    if status not in SAMPLE_STATUS_VALUES:
        errors.append("Status must be one of: " + ", ".join(SAMPLE_STATUS_VALUES))
    return errors, donor_id, sample_type_id, event_id, collection_date, volume_ml, status


@app.route("/samples/new", methods=["GET", "POST"])
def samples_new():
    donors, types, events = _lookups()
    if request.method == "POST":
        errors, donor_id, sample_type_id, event_id, collection_date, volume_ml, status = _validate_sample(request.form)
        if errors:
            for e in errors:
                flash(e, "error")
            return render_template("sample_form.html", sample=request.form, donors=donors,
                                    types=types, events=events, status_values=SAMPLE_STATUS_VALUES, mode="new")
        try:
            db.execute(
                "INSERT INTO Sample (donor_id, sample_type_id, event_id, collection_date, volume_ml, status) "
                "VALUES (?, ?, ?, ?, ?, ?)",
                (donor_id, sample_type_id, event_id, collection_date, volume_ml, status),
            )
            flash("Sample created.", "success")
            return redirect(url_for("samples_list"))
        except Exception as e:
            flash(f"Could not save sample: {e}", "error")
    return render_template("sample_form.html", sample={}, donors=donors, types=types,
                            events=events, status_values=SAMPLE_STATUS_VALUES, mode="new")


@app.route("/samples/<int:sample_id>/edit", methods=["GET", "POST"])
def samples_edit(sample_id):
    sample = db.fetchone("SELECT * FROM Sample WHERE sample_id = ?", (sample_id,))
    if not sample:
        flash("Sample not found.", "error")
        return redirect(url_for("samples_list"))
    donors, types, events = _lookups()

    if request.method == "POST":
        errors, donor_id, sample_type_id, event_id, collection_date, volume_ml, status = _validate_sample(request.form)
        if errors:
            for e in errors:
                flash(e, "error")
            merged = dict(sample); merged.update(request.form)
            return render_template("sample_form.html", sample=merged, donors=donors, types=types,
                                    events=events, status_values=SAMPLE_STATUS_VALUES, mode="edit")
        try:
            db.execute(
                "UPDATE Sample SET donor_id=?, sample_type_id=?, event_id=?, collection_date=?, "
                "volume_ml=?, status=? WHERE sample_id=?",
                (donor_id, sample_type_id, event_id, collection_date, volume_ml, status, sample_id),
            )
            flash("Sample updated.", "success")
            return redirect(url_for("samples_list"))
        except Exception as e:
            flash(f"Could not update sample: {e}", "error")

    return render_template("sample_form.html", sample=sample, donors=donors, types=types,
                            events=events, status_values=SAMPLE_STATUS_VALUES, mode="edit")


@app.route("/samples/<int:sample_id>/delete", methods=["POST"])
def samples_delete(sample_id):
    try:
        db.execute("DELETE FROM Sample WHERE sample_id = ?", (sample_id,))
        flash("Sample deleted.", "success")
    except Exception as e:
        flash(f"Could not delete sample (it may have related aliquots): {e}", "error")
    return redirect(url_for("samples_list"))


# --------------------------------------------------------------------------
# Test Requests CRUD
# --------------------------------------------------------------------------
@app.route("/test-requests")
def requests_list():
    search = request.args.get("q", "").strip()
    sql = """
        SELECT tr.*, s.sample_id AS sid, d.donor_code, r.full_name
        FROM TestRequest tr
        JOIN Sample s ON tr.sample_id = s.sample_id
        JOIN Donor d ON s.donor_id = d.donor_id
        JOIN Researcher r ON tr.researcher_id = r.researcher_id
        WHERE 1=1
    """
    params = []
    if search:
        sql += " AND (r.full_name LIKE ? OR tr.test_type LIKE ?)"
        params += [f"%{search}%", f"%{search}%"]
    sql += " ORDER BY tr.request_id"
    rows = db.fetchall(sql, tuple(params))
    return render_template("requests_list.html", rows=rows, search=search)


def _request_lookups():
    samples = db.fetchall(
        "SELECT s.sample_id, d.donor_code, st.type_name FROM Sample s "
        "JOIN Donor d ON s.donor_id = d.donor_id "
        "JOIN SampleType st ON s.sample_type_id = st.sample_type_id ORDER BY s.sample_id"
    )
    researchers = db.fetchall("SELECT researcher_id, full_name FROM Researcher ORDER BY full_name")
    return samples, researchers


def _validate_request(form):
    errors = []
    sample_id = form.get("sample_id", "").strip()
    researcher_id = form.get("researcher_id", "").strip()
    test_type = form.get("test_type", "").strip()
    request_date = form.get("request_date", "").strip()
    status = form.get("status", "").strip()

    if not sample_id:
        errors.append("Sample is required.")
    if not researcher_id:
        errors.append("Researcher is required.")
    if not test_type:
        errors.append("Test type is required.")
    if not request_date:
        errors.append("Request date is required.")
    if status not in REQUEST_STATUS_VALUES:
        errors.append("Status must be one of: " + ", ".join(REQUEST_STATUS_VALUES))
    return errors, sample_id, researcher_id, test_type, request_date, status


@app.route("/test-requests/new", methods=["GET", "POST"])
def requests_new():
    samples, researchers = _request_lookups()
    if request.method == "POST":
        errors, sample_id, researcher_id, test_type, request_date, status = _validate_request(request.form)
        if errors:
            for e in errors:
                flash(e, "error")
            return render_template("request_form.html", req=request.form, samples=samples,
                                    researchers=researchers, status_values=REQUEST_STATUS_VALUES, mode="new")
        try:
            db.execute(
                "INSERT INTO TestRequest (sample_id, researcher_id, test_type, request_date, status) "
                "VALUES (?, ?, ?, ?, ?)",
                (sample_id, researcher_id, test_type, request_date, status),
            )
            flash("Test request created.", "success")
            return redirect(url_for("requests_list"))
        except Exception as e:
            flash(f"Could not save request: {e}", "error")
    return render_template("request_form.html", req={}, samples=samples, researchers=researchers,
                            status_values=REQUEST_STATUS_VALUES, mode="new")


@app.route("/test-requests/<int:request_id>/edit", methods=["GET", "POST"])
def requests_edit(request_id):
    req = db.fetchone("SELECT * FROM TestRequest WHERE request_id = ?", (request_id,))
    if not req:
        flash("Request not found.", "error")
        return redirect(url_for("requests_list"))
    samples, researchers = _request_lookups()

    if request.method == "POST":
        errors, sample_id, researcher_id, test_type, request_date, status = _validate_request(request.form)
        if errors:
            for e in errors:
                flash(e, "error")
            merged = dict(req); merged.update(request.form)
            return render_template("request_form.html", req=merged, samples=samples,
                                    researchers=researchers, status_values=REQUEST_STATUS_VALUES, mode="edit")
        try:
            db.execute(
                "UPDATE TestRequest SET sample_id=?, researcher_id=?, test_type=?, request_date=?, "
                "status=? WHERE request_id=?",
                (sample_id, researcher_id, test_type, request_date, status, request_id),
            )
            flash("Test request updated.", "success")
            return redirect(url_for("requests_list"))
        except Exception as e:
            flash(f"Could not update request: {e}", "error")

    return render_template("request_form.html", req=req, samples=samples, researchers=researchers,
                            status_values=REQUEST_STATUS_VALUES, mode="edit")


@app.route("/test-requests/<int:request_id>/delete", methods=["POST"])
def requests_delete(request_id):
    try:
        db.execute("DELETE FROM TestRequest WHERE request_id = ?", (request_id,))
        flash("Test request deleted.", "success")
    except Exception as e:
        flash(f"Could not delete request: {e}", "error")
    return redirect(url_for("requests_list"))


if __name__ == "__main__":
    app.run(debug=True, port=5000)
