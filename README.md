## Darkfi Contributor Starter Pack

The easiest way to join the DarkFi community and start contributing

The goal of this setup is to provide an simple `docker-compose.yml` that by running it, anyone can contribute and participate to the community.

### Communicate

`ircd` is the communication platform that is used by DarkFi to communicate. It's an _encrypted_ and _p2p_ implementation of the IRC protocol on top of the DarkFi stack.

### Task Management

`taud` is the tool that is going to be used by the team to track tasks, but it's not currently used. 

### Networking

[Tor](https://www.torproject.org/) and [Tailscale](https://tailscale.com) is used for networking.

- `ircd` and `taud` are configured to be exposed to the internet as **Tor hidden services**
- `tailscale` is used for the connection between the user's device and the server. This is used so that the user can connect their IRC client or `tau` client from anywhere with ease

```
     ┌──────────┐          ┌────────────────┐          ┌───────────────────┐          ┌────┐              ┌─────────────┐             ┌───────────┐          ┌─────────┐
     │irc_client│          │tailscale_server│          │tailscale_container│          │ircd│              │tor_container│             │tor_network│          │ircd_peer│
     └────┬─────┘          └───────┬────────┘          └─────────┬─────────┘          └─┬──┘              └──────┬──────┘             └─────┬─────┘          └────┬────┘
          │  Connect to container  │                             │                      │                        │                          │                     │     
          │ ───────────────────────>                             │                      │                        │                          │                     │     
          │                        │                             │                      │                        │                          │                     │     
          │                        │    Connect to container     │                      │                        │                          │                     │     
          │                        │ ───────────────────────────>│                      │                        │                          │                     │     
          │                        │                             │                      │                        │                          │                     │     
          │                        │                             │ connect to IRC API   │                        │                          │                     │     
          │                        │                             │─────────────────────>│                        │                          │                     │     
          │                        │                             │                      │                        │                          │                     │     
          │                        │    IRC server response      │                      │                        │                          │                     │     
          │ <────────────────────────────────────────────────────────────────────────────                        │                          │                     │     
          │                        │                             │                      │                        │                          │                     │     
          │                        │                             │                      │ ask for inbound address│                          │                     │     
          │                        │                             │                      │ ───────────────────────>                          │                     │     
          │                        │                             │                      │                        │                          │                     │     
          │                        │                             │                      │     inbound address    │                          │                     │     
          │                        │                             │                      │ <───────────────────────                          │                     │     
          │                        │                             │                      │                        │                          │                     │     
          │                        │                             │                      │  connect to Tor peers  │                          │                     │     
          │                        │                             │                      │ ───────────────────────>                          │                     │     
          │                        │                             │                      │                        │                          │                     │     
          │                        │                             │                      │                        │ advertise inbound address│                     │     
          │                        │                             │                      │                        │ 
          │                        │                             │                      │                        │                          │                     │     
          │                        │                             │                      │                        │   connect to tor peers   │                     │     
          │                        │                             │                      │                        │ ─────────────────────────>                     │     
          │                        │                             │                      │                        │                          │                     │     
          │                        │                             │                      │                        │  connect to TLS peers    │                     │     
          │                        │                             │                      │ ────────────────────────────────────────────────────────────────────────>     
     ┌────┴─────┐          ┌───────┴────────┐          ┌─────────┴─────────┐          ┌─┴──┐              ┌──────┴──────┐             ┌─────┴─────┐          ┌────┴────┐
     │irc_client│          │tailscale_server│          │tailscale_container│          │ircd│              │tor_container│             │tor_network│          │ircd_peer│
     └──────────┘          └────────────────┘          └───────────────────┘          └────┘              └─────────────┘             └───────────┘          └─────────┘

```

#### Open Ports

This setup exposes the following container ports to the host machine:
- **ircd**: port `6667` for the irc client to connect
- **taud**: port `23330` for the `tau` client to connect

## How to use

### Dependencies 

- [Docker-compose](https://docs.docker.com/compose/).
- IRC client (e.g [weechat](https://weechat.org))
- [Tailscale](https://tailscale.com)

## Installation

- Clone the project: `git clone https://odyslam/darkfi-starter`
- Enter the directory with `cd darkf-starter`
- Create and populate the `.env` files with the appropriate env variables
     - `ircd.env` 
     - `taud.env`
     - `taiscale.env`
- Run `docker compose up` (add the flag `-d` if you want it to run in the background)
- ✅

## Configuration

### Tailscale

#### API Key

[tailscale docs](https://tailscale.com/kb/1085/auth-keys/)

- Create a tailscale account
- Go to admin console and click on `Settings`
- Click on `Keys` in Personal Settings
- Generate an Auth key, use default settings
- Duplicate `tailscale.env.example`, rename it to `tailscale.env` and replace <auth_key> with the auth key you just copied

### IRCD

#### Private key

If `ircd` does not detect a private key, it will create a new private key for you and print the public key. Search for the following logs in the logs of the `ircd` service:

```
ircd  | Private key: ********
ircd  | Public key: Df3p14VZYSr7aHRJjH3sGWLqhqN3PGjxqGvBLhNbFRqF
ircd  | Adding the private key to ircd config...
```

If you already have a private key, duplicate `ircd.env.example` and replace `<private_key>` with the private key. If containers are already running, you will need to restart them (`docker compose restart`).

#### Add contacts

[ircd docs](https://darkrenaissance.github.io/darkfi/misc/ircd/specification.html#contactinfo)

To add a new contact, add the following env variable to `ircd.env` for every contact:
```
IRCD_CONTACT_<joe>=<public_key>
IRCD_CONTACT_<doe>=<public_key>
```
Replace `<joe>` or `<doe>` with the name of the contact. Replace the `<public_key>` with the  public key of the contact.

#### Add channels 

[ircd docs](https://darkrenaissance.github.io/darkfi/misc/ircd/specification.html#channelinfo)

To add a new channel, add the following env variable to `ircd.env` for every channel:
```
IRCD_CONTACT_<channel>=<secret>
```
Replace `<channel>` with the channel name (e.g `devteam`) and `<secret>` with the channel's secret.

### Connect your IRC client

- Make sure that the containers are running
- Open weechat (or any other client)
- Get the IP of the tailscale client that is running in the container. It should be named `docker` something.
- Add the server to the client `/server add darkfi <IP>`
- Connect `/connect darkfi`

## TAUD

Taud is a p2p task manager and issue tracker.

#### Add workspaces

To add a new workspace, add the following env variable to `taud.env`:
```
TAUD_WORKSPACE_<WORKSPACE_NAME>=<private_key>
```

#### Add nickname
To customise your nickname, add the following env variable to `taud.env`:
```
TAUD_NICK=<nickname>
```

**Note**: If you don't assign a nickname, a random one will be automatically assigned.

## Docker compose flavors

The docker compose files come in different flavours, each with different trust assumptions:

- `docker-compose.yaml`: The default and easiest setup. It uses my own images `odyslam/*` so that you don't have to build them. You trust that the images are not malicious.
- `docker-compose-build.yaml`: The same setup as the above, but the images are built when you run `docker compose up` or `balena push`. Much slower, but you are certain of what docker images  you will run.
- `docker-compose-no-tailscale.yaml`: You build the images and you **don't** want to use tailscale. It's up to you to take care of networking and remote access to the machine that runs the services. It's worth mentioning that tailscale container, due to it's nature, does require the `privileged` setting, so it's attack surface is larger than the rest of the containers.

## Deploy the setup

- Provision a linux server (e.g [Digital Ocean](https://www.digitalocean.com/pricing/droplets#basic-droplets)), install Docker and follow the instructions above
- Get a Raspbery pi (or similar single-board computer), install Linux and follow the instructions above.
- Get a Raspberry pi (or another server) (or similar single-board computer), flash balenaOS, and deploy it via [Balena](https://balena.io). This is the easiest way of all three, as with balena you also get remote device management out of the box (logs, remote terminal, etc.). If you use balena, instead of using the `.env` files, you will need to add the env variables via the platform as described in their [docs](https://docs.balena.io/learn/manage/variables/#:~:text=From%20the%20Device%20Summary%20page,button%20to%20add%20the%20variable).

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/odyslam/darkfi-starter>)

# License

AGPLv3
