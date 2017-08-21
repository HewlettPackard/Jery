import cx_Oracle;

def connectToOracle(ip, port, SID, user, passwd, threaded=False):
    dsn = cx_Oracle.makedsn(host = ip, port = port, service_name = SID)
    con = cx_Oracle.connect(user, passwd, dsn, threaded=threaded)
    return con

error_con = 0

try:
    con = connectToOracle("192.168.40.131", "1521", "HPEDB", "TPCE", "TPCE")
except cx_Oracle.DatabaseError as e:
    error, = e.args
    if error.code == 1017:
        print("Invalid username or password")
        error_con = 1
    elif error.code == 12154:
        print("TNS couldn't resolve the SID")
        error_con = 1
    elif error.code == 12543:
        print("Destination host not available")
        error_con = 1
    else:
        print("Unable to connect")
        error_con = 1

if error_con != 1:
    cur = con.cursor()
    # drop all functions
    f = open('./txns/drop_all_functions.sql')
    full_sql = f.read()
    sql_commands = full_sql.split(';')

    for sql_command in sql_commands:
        try:
            cur.execute(sql_command)
        except cx_Oracle.DatabaseError as e:
            error, = e.args
            if error.code != 900 and error.code != 1435 and error.code != 4043 and error.code != 1031:
                print error
                error_con = 2
    if error_con == 0:
        print "dropped all functions"

    cur.close()
    con.close()

try:
    con = connectToOracle("192.168.40.131", "1521", "HPEDB", "TPCE", "TPCE")
except cx_Oracle.DatabaseError as e:
    error, = e.args
    if error.code == 1017:
        print("Invalid username or password")
        error_con = 1
    elif error.code == 12154:
        print("TNS couldn't resolve the SID")
        error_con = 1
    elif error.code == 12543:
        print("Destination host not available")
        error_con = 1
    else:
        print("Unable to connect")
        error_con = 1

if error_con != 1:
    cur = con.cursor()
    #create packages
    f = open('./txns/Brokervolume_pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/CustomerPosition_pkg.sql')
    full_sql = f.read()

    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/DataMaintenanceFrame1_Pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/MarketFeedFrame1_Pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/MarketWatchFrame1_Pkg.sql')
    full_sql = f.read()

    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/SecurityDetailFrame1_Pkg.sql')
    full_sql = f.read()

    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/TradeCleanupFrame1_Pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/TradeLookupFrame1_Pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/TradeOrderFrame1_Pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/TradeResultFrame1_Pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/TradeStatusFrame1_Pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2
    f = open('./txns/TradeUpdateFrame1_Pkg.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    if error_con == 0:
        print "created packages"

    #create functions

    f = open('./txns/broker_volume.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/CustomerPositionFrame1.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/DataMaintenance_mod.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/MarketFeedFrame1.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/MarketWatchFrame1_mod.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/SecurityDetailFrame1_mod.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/TradeCleanupFrame1.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/TradeLookupFrame1.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/TradeOrderFrame1.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/TradeResultFrame1.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/TradeStatusFrame1.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    f = open('./txns/TradeUpdateFrame1.sql')
    full_sql = f.read()
    try:
        cur.execute(full_sql)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code != 900:
            print error
            error_con = 2

    if error_con == 0:
        print "created functions"