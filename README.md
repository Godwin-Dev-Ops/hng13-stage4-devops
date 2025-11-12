🏗️ Linux VPC CLI

Virtual Private Cloud Simulation using Linux Namespaces, Bridges, and veth pairs

📖 Overview

This project implements a lightweight Virtual Private Cloud (VPC) on Linux using only native networking tools (ip, ip netns, bridge, iptables).
It mimics cloud-level network isolation, routing, and NAT functionality.

The CLI supports:

Creating and deleting isolated VPC environments

Setting up public and private subnets

Configuring internet access (via NAT)

Defining firewall rules using JSON-based security policies

Automating cleanup for repeatable testing

⚙️ Requirements
Variable	Description
VPC_NAME	Unique name for your virtual VPC
CIDR_BLOCK	Base IP range (e.g., 10.0.0.0/16)
PUBLIC_SUBNET	Subnet range that allows internet access (e.g., 10.0.1.0/24)
PRIVATE_SUBNET	Subnet range without internet access (e.g., 10.0.2.0/24)
INTERNET_INTERFACE	Your host’s external interface (e.g., eth0, enp0s3, etc.)

Dependencies:
Linux (Ubuntu 20.04+ recommended)
sudo privileges
iproute2, iptables, and bridge-utils installed

🚀 CLI Usage
1️⃣ Create a VPC
sudo ./vpcctl.sh create myvpc 10.0.0.0/16 10.0.1.0/24 10.0.2.0/24 eth0


Creates:
Two namespaces (ns-myvpc-public, ns-myvpc-private)
A Linux bridge (br-myvpc)
veth pairs connecting namespaces and the bridge
Routing and NAT rules for the public subnet
Logs of all configuration steps

2️⃣ Inspect the VPC
sudo ./vpcctl.sh inspect myvpc


Outputs:
Namespace list
Interfaces and assigned IPs
Bridge and veth connectivity
Routing tables for each namespace
Active firewall rules

3️⃣ Test Connectivity
Run inside your public namespace:
sudo ip netns exec ns-myvpc-public ping -c3 8.8.8.8


Run between namespaces:
sudo ip netns exec ns-myvpc-private ping -c3 10.0.1.10
If NAT is properly set, the public namespace should have internet access while the private one does not.

4️⃣ Apply Firewall Policies
Edit a JSON policy file, for example:

{
  "subnet": "10.0.1.0/24",
  "ingress": [
    {"port": 80, "protocol": "tcp", "action": "allow"},
    {"port": 22, "protocol": "tcp", "action": "deny"}
  ]
}


Then apply:
sudo ./vpcctl.sh apply-firewall myvpc firewall.json

5️⃣ Delete a VPC (Cleanup)
sudo ./vpcctl.sh delete myvpc


Removes:
Namespaces (ns-myvpc-public, ns-myvpc-private)
Bridge (br-myvpc)
veth pairs
iptables NAT and filter rules

Idempotent:
Running delete twice will not cause errors or duplicate removals.

🧪 Acceptance Test Commands (for Screenshots)
Below are the commands you can run to produce validation screenshots.

Test	Command	Expected Output
1. Verify VPC creation	sudo ./vpcctl.sh create myvpc 10.0.0.0/16 10.0.1.0/24 10.0.2.0/24 eth0	Logs showing bridge, veth, and namespace setup
2. Verify namespaces exist	ip netns list	Shows ns-myvpc-public, ns-myvpc-private
3. Inspect bridge and veths	brctl show	Shows br-myvpc connected to veths
4. Check IPs inside namespaces	sudo ip netns exec ns-myvpc-public ip a	Displays assigned IP (e.g., 10.0.1.10/24)
5. Test internet access	sudo ip netns exec ns-myvpc-public ping -c3 8.8.8.8	Successful replies
6. Test private isolation	sudo ip netns exec ns-myvpc-private ping -c3 8.8.8.8	100% packet loss
7. Test cross-subnet communication	sudo ip netns exec ns-myvpc-private ping -c3 10.0.1.10	Successful replies
8. Apply firewall rule	sudo ./vpcctl.sh apply-firewall myvpc firewall.json	Rule logs displayed
9. Delete all resources	sudo ./vpcctl.sh delete myvpc	Logs confirming cleanup
10. Confirm cleanup	ip netns list && brctl show	No ns-myvpc-* or br-myvpc entries
🪵 Sample Output Log (from CLI)
[+] Creating bridge br-myvpc ...
[+] Creating namespaces ns-myvpc-public, ns-myvpc-private ...
[+] Linking veth-public and veth-private ...
[+] Assigning IPs and enabling interfaces ...
[+] Configuring routes and NAT ...
[✔] VPC myvpc created successfully!

🧹 Cleanup Guarantee
The CLI:
Checks if resources already exist before creating them.
Cleans up all related interfaces, namespaces, and rules on deletion.
Prevents duplication on repeated runs.

You can safely re-run:
sudo ./vpcctl.sh create myvpc ...
sudo ./vpcctl.sh delete myvpc

📸 Recommended Screenshots for Submission
✅ Successful creation log
🌐 Public namespace ping to 8.8.8.8 (success)
🔒 Private namespace ping to 8.8.8.8 (failure)

🔄 Bridge (brctl show) output

🧱 Firewall test (port blocked)

🧹 Cleanup log (delete successful)
