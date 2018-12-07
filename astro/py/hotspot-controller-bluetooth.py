from wifi import Cell
from wifi.exceptions import InterfaceError
import sys
import signal
from bluetooth import BluetoothSocket, RFCOMM, PORT_ANY, advertise_service,\
    SERIAL_PORT_CLASS, SERIAL_PORT_PROFILE
from sh import nmcli, shutdown, reboot, ErrorReturnCode, sudo


typepswd = False
selectnet = False
ap = None
netscan = None
indiweb = None
username = None


def main():
    """
    Main method of the application.
    Must be run with superuser permissions.
    Params: <user> <network_interface> <hotspot_ssid> <hotspot_password>
    Creates the Bluetooth server and starts listening to clients.
    """
    if len(sys.argv) == 5:
        global netinterface
        global ap
        global hotspotssid
        global hotspotpswd
        global server_sock
        global client_sock
        global username
        signal.signal(signal.SIGINT, signal_handler)
        username = sys.argv[1]
        print("Username = " + username)
        netinterface = sys.argv[2]
        print("NetworkInterface = \"" + netinterface + "\"")
        hotspotssid = sys.argv[3]
        print("Hotspot SSID = " + hotspotssid)
        hotspotpswd = sys.argv[4]
        print("Hotspot password = " + hotspotpswd)

        server_sock = BluetoothSocket(RFCOMM)
        server_sock.bind(("", PORT_ANY))
        server_sock.listen(1)
        port = server_sock.getsockname()[1]
        uuid = "b9029ed0-6d6a-4ff6-b318-215067a6d8b1"
        advertise_service(server_sock, "PiBTControl",
                          service_id=uuid,
                          service_classes=[uuid, SERIAL_PORT_CLASS],
                          profiles=[SERIAL_PORT_PROFILE],
                          #                   protocols = [ OBEX_UUID ]
                          )
        while True:
            print("Waiting for connection on RFCOMM channel %d" % port)
            client_sock, client_info = server_sock.accept()
            print("Accepted connection from " + str(client_info))
            log("Welcome!\nUsing network interface \"" + netinterface + "\"")
            print_cmds()
            try:
                while True:
                    data = client_sock.recv(1024)
                    if len(data) == 0:
                        break
                    parse_rfcomm(data.replace("\n", "").strip())
            except IOError:
                pass
            print("Disconnecting...")
            client_sock.close()
    else:
        print("Usage: sudo python hotspot-controller-bluetooth.py"
              + "<user> <network_interface> <hotspot_ssid> <hotspot_password>")
        exit(1)


def print_cmds():
    """
    Prints all the available commands to stdout and the client.
    """
    log("Select an option:\n"
        + "  1. Start hotspot\n"
        + "  2. Stop hotspot\n"
        + "  3. Connect to Wi-Fi AP\n"
        + "  4. Start/restart INDI Web Manager\n"
        + "  5. Shutdown\n"
        + "  6. Reboot")


def parse_rfcomm(line):
    """
    Parses the command received from the client and executes it.
    """
    global typepswd
    global ap
    global selectnet
    global netscan
    if typepswd is True:
        log("Connecting...")
        try:
            log(str(nmcli("device", "wifi", "connect", ap, "password", line))
                .replace("\n", ""))
        except ErrorReturnCode:
            log("Error!")
            print_cmds()
        typepswd = False
        print_cmds()
    else:
        if len(line) == 1:
            cmdchar = line[0]
            if selectnet:
                index = ord(cmdchar) - 97
                if 0 <= index < len(netscan):
                    ap = str(netscan[index].ssid)
                    connect(ap)
                else:
                    log("Invalid selected network!")
                    print_cmds()
                selectnet = False
            elif cmdchar == '1':
                log("Starting hotspot...")
                start_hotspot()
                print_cmds()
            elif cmdchar == '2':
                log("Turning off hotspot...")
                stop_hotspot()
                print_cmds()
            elif cmdchar == '3':
                log("Network scan...")
                netdiscovery()
            elif cmdchar == '4':
                indiweb_start()
            elif cmdchar == '5':
                log("Shutdown!")
                shutdown("now")
            elif cmdchar == '6':
                log("Reboot!")
                reboot("now")
            else:
                log("Invalid command!")
                print_cmds()
        else:
            log("Invalid command!")
            print_cmds()


def signal_handler(sig, frame):
    """
    Handles the signals sent to this process.
    """
    print('Exiting...')
    if 'server_sock' in globals():
        global server_sock
        if server_sock is not None:
            try:
                server_sock.close()
            except IOError:
                print("IOError while closing server socket!")
    if 'client_sock' in globals():
        global client_sock
        if client_sock is not None:
            try:
                client_sock.close()
            except IOError:
                print("IOError while closing client socket!")
        client_sock.close()
    kill_indi()
    sys.exit(0)


def log(message):
    """
    Prints a message to stdout and to the client.
    """
    global client_sock
    print(message)
    client_sock.send(message + "\n")


def start_hotspot():
    """
    Starts the hotspot using nmcli.
    SSID and password are retrieved from global vars.
    """
    global hotspotssid
    global hotspotpswd
    try:
        log(str(nmcli("device", "wifi", "hotspot", "con-name", hotspotssid,
                      "ssid", hotspotssid, "band", "bg", "password",
                      hotspotpswd)).replace("\n", ""))
        log("SSID: " + hotspotssid + "\nPassword: " + hotspotpswd)
    except ErrorReturnCode:
        log("Error!")


def stop_hotspot():
    """
    Stops the hotspot nmcli.
    """
    try:
        log(str(nmcli("connection", "down", hotspotssid)).replace("\n", ""))
    except ErrorReturnCode:
        log("Error!")


def netdiscovery():
    """
    Looks for Wi-Fi APs and asks the user to select one.
    """
    global selectnet
    global netinterface
    global netscan
    try:
        netscan = Cell.all(netinterface)
        log("Select an access point:")
        index = 97
        for el in netscan:
            log("  " + chr(index) + ") " + el.ssid + ": " + el.quality)
            index = index + 1
        selectnet = True
    except InterfaceError:
        log("Unable to scan!")
        print_cmds()


def connect(ap):
    """
    Connects to the Wi-Fi AP that has the given SSID.
    Uses nmcli.
    """
    global typepswd
    try:
        log(str(nmcli("connection", "up", "id", ap)).replace("\n", ""))
        print_cmds()
    except ErrorReturnCode:
        log("Password for \"" + ap + "\":")
        typepswd = True


def indiweb_start():
    """
    Starts (or restarts) the INDI Web Manager.
    Must be installed.
    """
    global username
    global indiweb
    kill_indi()
    log("Starting INDI Web Manager...")
    try:
        indiweb = sudo("-u", username, "./indi-web",
                       _bg=True, _out=log_indi, _done=clean_indi)
    except ErrorReturnCode:
        log("Error in INDI Web Manager!")


def log_indi(line):
    """
    Sends the indiweb output to stdout and the client.
    """
    log("INDI: " + line.replace("\n", ""))


def kill_indi():
    """
    Kills indiweb if running.
    """
    global indiweb
    if indiweb is not None:
        log("Killing old INDI processes...")
        indiweb.terminate()
        indiweb.kill_group()


def clean_indi():
    """
    Makes the indiweb var equal to None
    """
    global indiweb
    indiweb = None


if __name__ == "__main__":
    main()
