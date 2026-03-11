#!/usr/bin/env python3
# SPU-13 Fleet Conductor (v1.0)
# Objective: Orchestrate a Global Laminar Flush (Sovereign Purification).
# Vibe: A synchronized ripple of coherency across the fleet.

import serial
import serial.tools.list_ports
import threading
import sys

def flush_node(port_name):
    """Execute the Laminar Flush on a specific node."""
    try:
        with serial.Serial(port_name, 115200, timeout=2) as ser:
            print(f"[*] Port {port_name}: Requesting Purification...")
            ser.write(b'FLUSH\n') # The Sovereign Trigger
            
            # Wait for acknowledging 'SANE' or 'SNTY' pulse
            response = ser.read(100).decode(errors='ignore')
            if "SANE" in response or "SNTY" in response:
                print(f"[+] Port {port_name}: PURIFIED. Sierpiński Seed injected.")
            else:
                print(f"[!] Port {port_name}: Handshake incomplete. Manifold is turbulent.")
    except Exception as e:
        print(f"[X] Port {port_name}: Connection severed. {e}")

def broadcast_flush():
    # Identify all SPU-13 nodes (Typically via iCELink or FTDI descriptions)
    ports = [p.device for p in serial.tools.list_ports.comports() if "USB" in p.description or "iCE" in p.description]
    
    if not ports:
        print("Error: No Sovereign Nodes detected in the Artery.")
        return

    print(f"--- Initiating Global Laminar Flush: {len(ports)} Nodes ---")
    threads = []
    for p in ports:
        t = threading.Thread(target=flush_node, args=(p,))
        threads.append(t)
        t.start()

    for t in threads:
        t.join()
    
    print(f"--- Fleet Coherency Restored. The Manifold is at Unity. ---")

if __name__ == "__main__":
    broadcast_flush()
