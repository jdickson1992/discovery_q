 🔎 A discovery service using a pub/sub model designed in `kdb+`.
 
 
# Getting started 🚀

To get started, just run:

```bash
./start.sh
```

- This script will *loop through an array of services*, starting each service as a background process using the `nohup` command.
- It will then bring up a Docker container 🐳 that contains a simple dashboard created using `HTML / js`
  - This dashboard uses websockets to communicate with a kdb+ discovery service. 
  - It can be accessed by going to `localhost:8080` on your browser
  - Input `localhost:9090` into the dashboard to connect to the discovery service

For e.g.:

<img width="1305" alt="Screenshot 2023-02-06 at 17 44 54" src="https://user-images.githubusercontent.com/47530786/217046035-20783f57-ff76-4873-b5bc-8dbec9c9fb41.png">


---

To **check the logs** of the `q` processes, run the below bash script(`stderr/stdout` *have been redirected to log files*):
```bash
./check_logs
```

For e.g.

<img width="1252" alt="Screenshot 2023-02-06 at 17 08 38" src="https://user-images.githubusercontent.com/47530786/217037666-8f59adcd-4369-4b4d-83b9-aa6145a84001.png">

---

To **kill** the background q processes, run the below bash script:
```bash
./kill.sh
```

This will provide you with an option to kill **a**ll (`a`) background processes or a **r**andom (`r`) background process. 

For e.g.

<img width="1599" alt="Screenshot 2023-02-06 at 17 11 36" src="https://user-images.githubusercontent.com/47530786/217038398-73c292ba-9a68-48a6-a2b8-139f6bad9fca.png">


---


# Dashboard 📊

If all services are **healthly**, all entries in the dashboard should be green 🟩:

https://user-images.githubusercontent.com/47530786/217034343-c8f3f7c7-a6a8-4a81-9fe3-0fc1109d268e.mov

If **after 30s** (*but less than 90s*), the discovery service hasn't received a heartbeat, it will change the service entry to an orange hue signifying a warning 🟧:

https://user-images.githubusercontent.com/47530786/217039682-dd6adabc-b6ce-495c-934a-322f77b4b3fa.mov

If **after 90s**, the discovery service hasn't received a heartbeat, it will change the table entry to red indicating an error 🟥:


https://user-images.githubusercontent.com/47530786/217040259-e03b0fe6-a0ff-4b4e-bf48-df1c35a58353.mov


# Caveats ⚠️

1. Please check that `rlwrap` and `q` are installed and *findable* in your bash profile.
  - If not, then you will have to modify lines [57](https://github.com/jdickson1992/discovery_q/blob/87c8f010c4dd6222d6b2c288fbc3239846c5bf44/start.sh#L57) and [60](https://github.com/jdickson1992/discovery_q/blob/87c8f010c4dd6222d6b2c288fbc3239846c5bf44/start.sh#L60) of `start.sh`
