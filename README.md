
### This repo is no longer maintained. I suggest you to use [docker-compose](https://docs.docker.com/compose/) tool.

# Dockage [![Dependency Status](https://gemnasium.com/kressh/dockage.svg)](https://gemnasium.com/kressh/dockage) [![Code Climate](https://codeclimate.com/github/kressh/dockage/badges/gpa.svg)](https://codeclimate.com/github/kressh/dockage) [![Build Status](https://travis-ci.org/kressh/dockage.svg?branch=master)](https://travis-ci.org/kressh/dockage) [![Gem Version](https://badge.fury.io/rb/dockage.svg)](http://badge.fury.io/rb/dockage)

Ruby tool to manage multiple Docker containers at once


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dockage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dockage

## Usage

    $ dockage help

Create example configuration file with:

    $ dockage init

Modify it and run

    $ dockage up

## Configuration dockage.yml

  * **docker_host**  - docker daemon host (by default unix:///var/run/docker.sock) MacOSX users can use boot2docker LXC functionality
  * **containers** - array of containers
    * **name** - name of container
    * **image** - image to use for docker pull
    * **keep_fresh** - if true docker will check image for updates every time
    * **volumes** - array of volumes to mount (format: **HOST_PATH**:**CONTAINER_PATH**)
    * **ports** - array of ports to forward from container (format: **HOST_PORT**:**CONTAINER_PORT**)
    * **links** - array of links to other containers (format: **CONTAINER_NAME**:**CONTAINER_HOST_NAME**)
    * **cmd** - override container's CMD to run
    * **ssh** - SSH configuration
      * **login** - SSH login
      * **host** - SSH host. In most cases docker daemon host.
      * **port** - SSH port. Forward this port to docker host.
      * **identity_key** - SSH private key file or string to authenticate with
    * **provision** - array of provision scripts. Can be script or inline. Requires SSH access to container.

## dockage.yml example

```
docker_host: tcp://localhost:2375
containers:
  - name: postgres
    image: postgres:latest
    keep_fresh: false
    cmd: 'usermod -u 1000 postgres && groupmod -g 1000 postgres && chown -R postgres /var/run/postgresql && /docker-entrypoint.sh postgres'
    volumes:
      - /home/username/data/postgres:/var/lib/postgres

  - name: myapp
    image: kr3ssh/debian-rails
    keep_fresh: true
    env:
      POSTGRES_HOST: postgres
      POSTGRES_PORT: 5432
      POSTGRES_USER: postgres
    ssh:
      forward_agent: true
      login: rack
      host: 127.0.0.1
      port: 2220
      identity_key: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAzLDckHc9OaK+aN46L845Xpr7/LCJpOuPYonFCKct4Nhw4BUU
        YqDDquhWlwzGGSjoHWTR33txZvWtj/kqSXYW/t86q2Wd5jwUmDpmMmSsMKAx5VLI
        KvdCCCgV9pr30taDpvsTjhNzXFo5E2fq+kYGlrfIiiMJ1tEZD5lS5XNTCCpaf73D
        8qOR6bIV0/PfrCcmr14aBIRmnJ+fHpW45I55QJI7ebQmpbLZjk0/H/Uaoyw5MDZC
        B8f0kwip4LNhTuRa/AHEeZC7fzzII00PluWzJNBWZ1Upw7/ZhsIp0Z00UBPCt9LF
        PugIGfAvqTmA3XnTqpL5Tl7ugOLnO7ikddN5DQIDAQABAoIBAQC9u8L3dk+eOShe
        dH9jCLlM5ERnegxcfq0uHZ4x4yU3oekfDOsUcxhuR2bcJM8LS0u801Nm4DnBwkDb
        j46PAZNXNPxhG5Q9cbt1T8yjMYYanKMjepRon0Dp5p5VNFg7avQlt93seEMae9ck
        EdNRoc9BraGJyei44qFkQC8C2N9CVLeWY3+kmcOj1DAWA4OFAVmm+gpAMOdhWJXe
        1QLrEF970qb4SDwofCp2LuLWIEL4PCIbYx6CqAMDH6PJmd8Xp18DMpRa5DzOLMeg
        +kyBmRIVHuCE/8tcvTu+wld4aqJodD34ct83OC8jZHM34JZ3SO+Bfe3CIQdRiQrw
        xnrmI3tRAoGBAOjU1ZlFz34OHpFeidvanN0lxSO6GBHV2qgU/Ut7EauvlftSq647
        8CUjofW8gdRRZfdYP38sSXQTYFSbsp3YAcqPJU+NVPANTudCyuL1jRlzdrfqmx5I
        pwl1EveDGHdiuOF9SlaYThzjU0OHetPH4+7dMn9U9NV+a4V3sBb2HCEDAoGBAOEP
        LGBhK6Eb0TIfQxqFpgFJ/8gcfiIp5xpNxJWHv3oGTDkYFa8cCKWbVAQjOxIHRbuz
        kMVt0KMB8oGhdDpQNK2KtDwGnI1rcxrSgmvCJGn2dTB/udL+DYAAKWFKg7+YJqXx
        WpV6uetd6EKSGChSqMLkwDUzDVA0NVpXWnoPivivAoGAX415W73audDxmpdB3IiL
        d/bYQSFOX4N0iSaUDTYkumEFHG+BJbBTjephvYfvgEMnpasB5B84xfptvktnsn/D
        vG204QEPqrTLfP1cZmh/z8IjJreRkYwfgTIa5plWoShS17PyDjfTVue0dDJVpjSS
        xqTg5IDpOfT4C35jkgkq4iECgYAKIkvGPznetEj0L9IutIvoDPP2h8nqMebVGWFb
        tlQZ44S1IW+AhguhoV/kG84CHs+2Bvzi1vIJFQJdce6w3YGxusgo18de2tLBB2+V
        +JT5LH7UYzvz0zq6Y8d5OQi7rNc4q6h/iJosjfryXG+4CRjORcyd2KGl1eP9IGfT
        jTWdwwKBgH3z9MMKbz9Hdi4FKMwtBr7iXrgqKtfCI4HIbd0bTHhdotE2a5fWxilW
        WoZvBVQxUY//oXZ98jk/YodPLLeq8l/BgEtU6ggtF1RMie+ovSqxLx+gvaUBapAc
        LqP4uSVmktuP/iZwBn9vlRkKiJo0chPNqYfzuknAcgeYgpT2zHDB
        -----END RSA PRIVATE KEY-----
    links:
      - postgres:postgres
    ports:
      - '2220:22'
      - '3000:3000'
    provision:
      - script: dockage/provision/nginx-config.sh
```

## Contributing

1. Fork it ( https://github.com/kressh/dockage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
