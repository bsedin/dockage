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
      * **identity_file** - SSH private key to authenticate with
    * **provision** - array of provision scripts. Can be script or inline. Requires SSH access to container.

## Contributing

1. Fork it ( https://github.com/kressh/dockage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
