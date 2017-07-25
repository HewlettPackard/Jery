########################################################################################################################
#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv CONFIG vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
import cx_Oracle

ip = '192.168.40.131'
port = 1521
SID = 'HPEDB'
user = 'TPCE'
passwdUsr = 'TPCE'
passwdSys = 'manager1'
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ CONFIG ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
########################################################################################################################



#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv HELPERS vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
def connectToOracle(ip, port, SID, user, passwd, threaded=False):
    dsn = cx_Oracle.makedsn(host = ip, port = port, service_name = SID)
    con = cx_Oracle.connect(user, passwd, dsn, threaded=threaded)
    return con

def establishConnection(ip, port, SID, user, passwd):
    error_con = 0

    try:
        con = connectToOracle(str(ip), str(port), str(SID), str(user), str(passwd))
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        if error.code == 1017:
            print str(SID) + ": Invalid username or password"
            error_con = 1
        elif error.code == 12154:
            print str(SID) + ": TNS couldn't resolve the SID"
            error_con = 1
        elif error.code == 12543:
            print str(SID) + ": Destination host not available"
            error_con = 1
        else:
            print str(SID) + ": Unable to connect"
            error_con = 1

    if error_con != 1:
        return con
    else:
        return False

def printDBMSoutput(cur):
    statusVar = cur.var(cx_Oracle.NUMBER)
    lineVar = cur.var(cx_Oracle.STRING)
    while True:
        cur.callproc("dbms_output.get_line", (lineVar, statusVar))
        if statusVar.getvalue() != 0:
            break
        print lineVar.getvalue()
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ HELPERS ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


def brokervolumeTransaction():
    con = establishConnection(ip, port, SID, user, passwdUsr)

    if con:
        cur = con.cursor()

        # get a random sector name
        cur.execute("""select SC_NAME from ( select SC_NAME, row_number() over (order by sc_name) 
                    rno from sector order by rno) where  rno = ( select round (dbms_random.value (0,11)) from dual)""")
        in_sector_name = cur.fetchall()[0][0]

        cur.callproc("dbms_output.enable")
        cur.execute("""
            DECLARE
            in_sector_name VARCHAR2(50);
            list_len INTEGER;
            status INTEGER;
            i INTEGER;

            in_broker_list  Brokervolume_pkg.B_NAME_ARRAY := Brokervolume_pkg.B_NAME_ARRAY ();
            broker_name  Brokervolume_pkg.B_NAME_ARRAY := Brokervolume_pkg.B_NAME_ARRAY ();
            volume Brokervolume_pkg.VOL_ARRAY := Brokervolume_pkg.VOL_ARRAY();
            brokervolframe1_tbl  Brokervolume_pkg.brokervolframe1_tab;

            BEGIN

            in_sector_name  := '""" + in_sector_name + """';
            SELECT b_name BULK COLLECT INTO in_broker_list FROM ( SELECT b_name , row_number() over (order by b_name) rno FROM broker )
                    WHERE  rno < ( SELECT round (dbms_random.value (25,50)) FROM dual) 
                    AND rno > ( SELECT round (dbms_random.value (0,25)) FROM dual);

            dbms_output.put_line('ins_sec: ' || in_sector_name);
            brokervolframe1_tbl := Brokervolume_pkg.BrokerVolumeFrame1(in_broker_list ,in_sector_name,broker_name,list_len,status,volume);

            dbms_output.put_line('list_len: ' || list_len);
            dbms_output.put_line('status_out: ' || status);
            --FOR i IN 1..30
            --LOOP
            --dbms_output.put_line('volume'|| volume(i));
            --END LOOP;
            END;
        """)

        printDBMSoutput(cur)

        cur.close()
        con.close()

if __name__ == "__main__":
    brokervolumeTransaction()
