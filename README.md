# Switch Orchestrator

## About

I started with this project because I wanted to search job logs on Switch quickly and simply. If you work most part of the time coding and switching between GUI and Terminal you know how to bother is to go to Switch to look at the logs

### Requirements

Switch Orchestrator uses a few simple tools that you probably already have installed.
A text editor (such as Vim or Emacs)
A program to print files (like cat)
Basic programs that should be included in almost all Linux/Unix distributions, including mkdir, touch, mv, rm, echo, printf
But I order to optimize the developement two libraries are required, specially for deal with json files.
JQ <https://github.com/stedolan/jq>
JTBL <https://kellyjonbrazil.github.io/jtbl/>

### Usage

#### Before Start

Starting from the folder that swo.sh is located

```bash
chmod +x swo.sh
sudo cp swo.sh /usr/local/bin/swo
```

Create a file `swo_config` on `$HOME/.config/switchOrchestrator`
Please read the oficial manual of [Enfocus Switch API](https://www.enfocus.com/manuals/DeveloperGuide/WebServices/17/index.html#api-Authentication-LoginQuery) to learn how create a password hash

```bash
USER="log"
HASH_PASS="XXXXXXXXXXXXXXXX"
SWITCH_IP="0.0.0.0"

```

#### Auth

This command will save a token used to make the API calls

```bash
swo -a
```

#### Search for Job

```bash
swo -j EA-12-123123
```

#### Options

| Options                      | Description           |
| ---------------------------- | --------------------- |
| `-a --auth`                  | authentication        |
| `-j <string> --job <string>` | search a job          |
| `-h --help`                  | display help dialog   |
| `-i --install`               | create config folders |

### How do I contribute to Switch Orchestrator?

I'm far from expert and suspect there are many ways to improve. If you have ideas on how to make this project better, don't hesitate to fork and send pull requests!

### Authors

```Bruno Bertolani``` [LinkedIn](https://www.linkedin.com/in/brunosbertolani/)

### Research used on this project

<https://stackoverflow.com/questions/39139107/how-to-format-a-json-string-as-a-table-using-jq>
<https://www.makeareadme.com/>
<https://www.enfocus.com/manuals/DeveloperGuide/WebServices/17/index.html#api-Authentication-LoginQuery>
<https://makefiletutorial.com/#commands-and-execution>

### Next Features

- [X] Authentication
- [X] Search by Jobs
- [ ] Search with different parameters
- [ ] Refresh Search
- [ ] List Workflow
- [ ] Start/Stop workflow
- [ ] Multiple Switch
- [ ] Environment ?
- [ ] Sync multiple scripts between enviroments
- [ ] Migrate to python ?
