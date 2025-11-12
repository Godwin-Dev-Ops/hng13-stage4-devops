  #!/bin/bash
  These commands are to be used with "sudo"
  Run them one after the other, to be able to track erros

  ./vpcctl create
  ./vpcctl deploy-app
  curl 192.168.50.1:8080
  curl 10.20.0.1:8080
  ip netns exec ns-public ping 192.168.50.2 -c 4
  ip netns exec ns-public ping 8.8.8.8 -c 4
  ip netns exec ns-private ping 8.8.8.8 -c 4
  ./vpcctl peer
  ip netns exec ns-public ping 10.20.0.1 -c 4
  ./vpcctl apply-policy policy.json


  ip netns exec ns-public python3 -m http.server 80 --bind 192.168.50.1
  curl 192.168.50.1:80

  ip netns exec ns-public python3 -m http.server 443 --bind 192.168.50.1

  curl 192.168.50.1:443

  ip netns exec ns-public python3 -m http.server 22 --bind 192.168.50.1

  nc -zv 192.168.50.1 22

  ./vpcctl teardown
