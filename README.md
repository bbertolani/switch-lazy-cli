# **switch-lazy-cli**

## **About**

**switch-lazy-cli** is a command-line tool designed to simplify the process of searching work logs on **Enfocus Switch**. If you frequently switch between a GUI and the terminal while coding, you know how inconvenient it can be to check logs manually. This tool streamlines the process, allowing you to access logs quickly and efficiently.

![Switch Lazy CLI](./assets/swo.png)

---

## **Requirements**

**switch-lazy-cli** depends on a few common Linux/Unix utilities. Ensure that your system has the following tools installed:

- **Basic utilities**: `vim`, `emacs` (text editors), `cat` (print files), `mkdir`, `touch`, `mv`, `rm`, `echo`, `printf`
- **Additional libraries**:  
  - **JQ** - A JSON processor  
    - [JQ GitHub Repository](https://github.com/stedolan/jq)  
  - **JTBL** - JSON to table converter  
    - [JTBL GitHub Repository](https://kellyjonbrazil.github.io/jtbl)  

- **Most importantly:**  
  - You must have **Enfocus Switch** with **API support (from 2018)**.

---

## **Installation**

### **Clone the Repository**
First, clone this repository:

```bash
git clone https://github.com/yourusername/switch-lazy-cli.git
cd switch-lazy-cli
```

### **Make the Script Executable**
Navigate to the folder where `swo.sh` is located and make it executable:

```bash
chmod +x swo.sh
```

### **Move the Script for System-wide Access**
Copy the script to `/usr/local/bin` to make it accessible from anywhere:

```bash
sudo cp swo.sh /usr/local/bin/swo
```

---

## **Configuration**

### **Create Configuration File**
1. Create a configuration file at:  
   ```
   $HOME/.config/switchOrchestrator/swo_config
   ```
   Or run:
   ```bash
   swo -c
   ```

2. Add the following information to the configuration file:

   ```bash
   USER="joe"
   HASH_PASS="XXXXXXXXXXXXXXXX"
   SWITCH_IP="0.0.0.0"
   ```

### **Password Hash (Authentication)**

To authenticate, you need to generate an encrypted password hash.

#### **Steps:**
1. Create a `enfocuspublic_key.pem` file.
2. Copy the **PUBLIC KEY** from the [Enfocus Switch - Auth Documentation](https://www.enfocus.com/manuals/DeveloperGuide/WebServices/17/index.html#api-Authentication-LoginQuery).
3. Run the following command to encrypt your password:

   ```bash
   echo -n "REPLACEYOURPASSWORDHERE" | openssl rsautl -encrypt -pubin -inkey ./enfocuspublic_key.pem | base64
   ```

> ⚠ **Warning:**  
> If you are unfamiliar with **RSA encryption**, research before proceeding. Encryption operations should be performed at your own risk.  
> [Check it](https://letmegooglethat.com/?q=Encrypt+rsa+password+online)

---

## **Usage**

### **Authentication**
Authenticate and generate an authentication token:

```bash
swo -a
```

This command stores the token, which is necessary for making API calls.

---

### **Search for a Job**
Retrieve details about a specific job:

```bash
swo -j JOBNUMBER
```

**Example Output:**

```bash
^ type   ^ flow                  ^ job                  ^ element                       ^ message                                                                  ^ timestamp                ^
| info   | test-flow live        |                      | New Job                       | Added unique name prefix, new name is '_J79O5_test-job swo.xml'          | 2024-02-17T00:06:22.617Z |
| info   | test-flow live        | test-job swo.xml     | XML action                    | Metadata was attached to asset '/Users/_J79O5_test-job swo.xml'          | 2024-02-17T00:06:22.744Z |
| info   | test-flow live        | test-job swo.xml     | XML action                    | File _J79O5_test-job swo.xml was renamed to file _J79O5_test-job swo.xml | 2024-02-17T00:06:22.750Z |
```

---

### **List Existing Flows**
Retrieve the status, name, and groups of existing flows:

```bash
swo -f
```

**Example Output:**

```bash
^ status   ^ name       ^ groups   ^
| running  | Example A  | INPUT    |
| stopped  | Example B  | ACTION   |
| running  | Example C  | ACTION   |
| stopped  | Example D  | MACHINE  |
```

> **Color-coding:**  
> - ✅ **Running flows** → **Green**  
> - ❌ **Stopped flows** → **Red**

---

## **Options**

| Option                         | Description                     |
|--------------------------------|---------------------------------|
| `-a, --auth`                   | Authenticate and obtain a token |
| `-j <string>, --job <string>`  | Search for a job                |
| `-h, --help`                   | Display help information        |
| `-i, --install`                | Create configuration folders    |
| `-f, --flows`                  | List flows and statuses         |

---

## **How to Contribute?**
I'm far from an expert, and I believe there are many ways to improve this project. If you have ideas, feel free to **fork** the repository and send a **pull request**!

---

## **Author**
👤 **Bruno Bertolani**  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-BrunoBertolani-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/brunosbertolani/)

---

## **References & Research**
This project was developed using insights from:

- [Formatting JSON as a Table using JQ](https://stackoverflow.com/questions/39139107/how-to-format-a-json-string-as-a-table-using-jq)
- [How to Write a Great README](https://www.makeareadme.com/)
- [Enfocus Switch API Authentication](https://www.enfocus.com/manuals/DeveloperGuide/WebServices/17/index.html#api-Authentication-LoginQuery)
- [Makefile Tutorial](https://makefiletutorial.com/#commands-and-execution)

---

## **Planned Features 🚀**

- [x] Authentication
- [x] Search by Jobs
- [ ] Search using different parameters
- [ ] Refresh search results
- [x] List workflows
- [ ] Start/Stop workflows
- [ ] Support for multiple Enfocus Switch instances
- [ ] Environment support?
- [ ] Synchronize multiple scripts between environments
- [ ] Migrate to Python?

---

> 📌 **Note:**  
> This project is NOT actively evolving, and any suggestions or improvements are highly welcome! 🚀
