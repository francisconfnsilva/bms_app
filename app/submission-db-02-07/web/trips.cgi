#!/usr/bin/python3
import cgi
import cgitb; cgitb.enable()
from db import get_connection
import html

print("Content-type: text/html\n")
print("""
<html>
<head>
    <title>Trips</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .container { max-width: 1400px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .back-link { display: inline-block; margin-bottom: 20px; color: #3498db; text-decoration: none; font-weight: bold; }
        .back-link:hover { text-decoration: underline; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 13px; }
        th { background-color: #3498db; color: white; padding: 10px; text-align: left; }
        td { border: 1px solid #ddd; padding: 8px; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        tr:hover { background-color: #f0f0f0; }
        .form-box { background-color: #f9f9f9; padding: 20px; border-radius: 5px; border: 1px solid #ddd; }
        label { display: block; margin: 10px 0 5px 0; color: #555; font-weight: bold; }
        input[type="date"], input[type="text"], select { width: 100%; max-width: 400px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        input:focus, select:focus { outline: none; border-color: #3498db; }
        input[type="submit"], button { padding: 10px 20px; background-color: #27ae60; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; margin-top: 10px; }
        input[type="submit"]:hover, button:hover { background-color: #229954; }
        button.delete-btn { background-color: #e74c3c; padding: 6px 12px; font-size: 13px; margin: 0; }
        button.delete-btn:hover { background-color: #c0392b; }
        .message { padding: 12px; margin: 15px 0; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px; color: #155724; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .inline-form { display: inline; }
    </style>
</head>
<body>
<div class="container">
    <a href='menu.cgi' class="back-link"> Back to Menu</a>
    <h1>Trips</h1>
""")

form = cgi.FieldStorage()
action = form.getvalue('action')

conn = None
try:
    conn = get_connection()
    conn.autocommit = False
    cur = conn.cursor()

    # CREATE trip
    if action == 'create':
        takeoff = form.getvalue('takeoff')
        arrival = form.getvalue('arrival')
        insurance = form.getvalue('insurance')
        reservation_key = form.getvalue('reservation')
        from_location = form.getvalue('from_location')
        to_location = form.getvalue('to_location')
        skipper = form.getvalue('skipper')

        if not all([takeoff, arrival, insurance, reservation_key, from_location, to_location, skipper]):
            print("<p class='error'>Error: All fields are required.</p>")
        else:
            # Parse reservation: "start_date|end_date|country|cni"
            if reservation_key and reservation_key.count('|') == 3:
                res_start, res_end, boat_country, cni = reservation_key.split('|', 3)
            else:
                res_start = res_end = boat_country = cni = None

            # Parse locations: "latitude|longitude"
            if from_location and '|' in from_location:
                from_lat, from_lon = from_location.split('|', 1)
            else:
                from_lat = from_lon = None

            if to_location and '|' in to_location:
                to_lat, to_lon = to_location.split('|', 1)
            else:
                to_lat = to_lon = None

            sql_ins = """
                INSERT INTO trip(
                    takeoff, arrival, insurance,
                    from_latitude, from_longitude,
                    to_latitude, to_longitude,
                    skipper,
                    reservation_start_date, reservation_end_date,
                    boat_country, cni
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            cur.execute(sql_ins, (
                takeoff, arrival, insurance,
                from_lat, from_lon,
                to_lat, to_lon,
                skipper,
                res_start, res_end,
                boat_country, cni
            ))

            conn.commit()
            print("<p class='message'> Trip created successfully.</p>")

    # DELETE trip
    elif action == 'delete':
        takeoff = form.getvalue('takeoff')
        res_start = form.getvalue('reservation_start_date')
        res_end = form.getvalue('reservation_end_date')
        boat_country = form.getvalue('boat_country')
        cni = form.getvalue('cni')

        sql_del = """
            DELETE FROM trip
            WHERE takeoff = %s
              AND reservation_start_date = %s
              AND reservation_end_date = %s
              AND boat_country = %s
              AND cni = %s
        """
        cur.execute(sql_del, (takeoff, res_start, res_end, boat_country, cni))
        conn.commit()
        print("<p class='message'> Trip deleted successfully.</p>")

    # LIST trips
    sql_list = """
        SELECT
            t.takeoff, t.arrival, t.insurance,
            loc_from.name AS from_name,
            loc_to.name AS to_name,
            t.skipper,
            t.reservation_start_date, t.reservation_end_date,
            t.boat_country, t.cni,
            b.name AS boat_name
        FROM trip t
        JOIN location loc_from
          ON t.from_latitude = loc_from.latitude
         AND t.from_longitude = loc_from.longitude
        JOIN location loc_to
          ON t.to_latitude = loc_to.latitude
         AND t.to_longitude = loc_to.longitude
        JOIN boat b
          ON t.boat_country = b.country
         AND t.cni = b.cni
        ORDER BY t.takeoff DESC
    """
    cur.execute(sql_list)
    trips = cur.fetchall()

    print("<h2>Existing Trips</h2>")
    if trips:
        print("<table>")
        print("<tr>")
        print("<th>Takeoff</th><th>Arrival</th><th>Insurance</th>")
        print("<th>From</th><th>To</th>")
        print("<th>Skipper</th><th>Boat</th><th>Reservation</th><th>Actions</th>")
        print("</tr>")

        for (takeoff, arrival, insurance, from_name, to_name, skipper,
             res_start, res_end, boat_country, cni, boat_name) in trips:

            print("<tr>")
            print(f"<td>{html.escape(str(takeoff))}</td>")
            print(f"<td>{html.escape(str(arrival))}</td>")
            print(f"<td>{html.escape(insurance)}</td>")
            print(f"<td>{html.escape(from_name)}</td>")
            print(f"<td>{html.escape(to_name)}</td>")
            print(f"<td>{html.escape(skipper)}</td>")
            print(f"<td>{html.escape(boat_country)} - {html.escape(cni)} ({html.escape(boat_name)})</td>")
            print(f"<td>{html.escape(str(res_start))} to {html.escape(str(res_end))}</td>")
            print("<td>")
            # Secure delete with POST form
            print("<form method='post' action='trips.cgi' class='inline-form'>")
            print("<input type='hidden' name='action' value='delete'/>")
            print(f"<input type='hidden' name='takeoff' value='{takeoff}'/>")
            print(f"<input type='hidden' name='reservation_start_date' value='{res_start}'/>")
            print(f"<input type='hidden' name='reservation_end_date' value='{res_end}'/>")
            print(f"<input type='hidden' name='boat_country' value='{boat_country}'/>")
            print(f"<input type='hidden' name='cni' value='{cni}'/>")
            print("<button type='submit' class='delete-btn'>Delete</button>")
            print("</form>")
            print("</td>")
            print("</tr>")
        print("</table>")
    else:
        print("<p>No trips registered.</p>")

    # Get data for form
    cur.execute("""
        SELECT r.start_date, r.end_date,
               r.country, r.cni, b.name
        FROM reservation r
        JOIN boat b ON r.country = b.country AND r.cni = b.cni
        ORDER BY r.start_date, r.country, r.cni
    """)
    reservations = cur.fetchall()

    cur.execute("""
        SELECT latitude, longitude, name, country_name
        FROM location
        ORDER BY country_name, name
    """)
    locations = cur.fetchall()

    cur.execute("SELECT email, firstname, surname FROM sailor ORDER BY email")
    sailors = cur.fetchall()

    # Create form
    print("<h2>Create Trip</h2>")

    if not reservations:
        print("<p class='error'>No reservations available. Please create a reservation first.</p>")
    elif not locations:
        print("<p class='error'>No locations available. Please add locations first.</p>")
    elif not sailors:
        print("<p class='error'>No sailors available. Please add sailors first.</p>")
    else:
        print("<div class='form-box'>")
        print("<form method='post' action='trips.cgi'>")
        print("<input type='hidden' name='action' value='create'/>")

        print("<label>Takeoff Date:</label>")
        print("<input type='date' name='takeoff' required/>")

        print("<label>Arrival Date:</label>")
        print("<input type='date' name='arrival' required/>")

        print("<label>Insurance Reference:</label>")
        print("<input type='text' name='insurance' required/>")

        print("<label>Reservation (Boat):</label>")
        print("<select name='reservation' required>")
        for start, end, country, cni, boat_name in reservations:
            value = f"{start}|{end}|{country}|{cni}"
            label = f"{start} to {end} - {country} - {cni} ({boat_name})"
            print(f"<option value='{value}'>{label}</option>")
        print("</select>")

        print("<label>From Location:</label>")
        print("<select name='from_location' required>")
        for lat, lon, name, country_name in locations:
            value = f"{lat}|{lon}"
            label = f"{name} ({country_name}) [{lat}, {lon}]"
            print(f"<option value='{value}'>{label}</option>")
        print("</select>")

        print("<label>To Location:</label>")
        print("<select name='to_location' required>")
        for lat, lon, name, country_name in locations:
            value = f"{lat}|{lon}"
            label = f"{name} ({country_name}) [{lat}, {lon}]"
            print(f"<option value='{value}'>{label}</option>")
        print("</select>")

        print("<label>Skipper:</label>")
        print("<select name='skipper' required>")
        for email, firstname, surname in sailors:
            label = f"{email} ({firstname} {surname})"
            print(f"<option value='{email}'>{label}</option>")
        print("</select>")

        print("<input type='submit' value='Create Trip'/>")
        print("</form>")
        print("</div>")

    cur.close()
except Exception as error:
    if conn is not None:
        conn.rollback()
    print("<p class='error'>An error occurred:</p>")
    print(f"<pre>{html.escape(str(error))}</pre>")
finally:
    if conn is not None:
        conn.close()

print("</div></body></html>")
