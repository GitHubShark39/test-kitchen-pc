# Test Kitchen Parent Child

Test Kitchen Parent-Child is a thin wrapper around Test Kitchen that adds
support for inheritance in the .kitchen.yml configuration files for multi-role
projects.

## What is this for?

While Test Kitchen is a phenomenal tool for testing a suite of infrastructure
code, it doesn't lend itself quite as well to testing many related suites that
are contained in the same project.

I'm coming at this from the Ansible world where I've got a single project that
houses all of my "roles" (machine profiles), and Test Kitchen is great for
testing each individual role.  The main pain point comes when these roles all
use the same set of test configurations, and it would be great to share configs
instead of duplicating them across dozens of roles.

Here's a sample directory structure of the type of project that this extension
was written to help test:

```
ansible-project/
├── roles/
│   ├── ssh-role/
│   |   ├── .kitchen.yml
│   |   └── ...
│   ├── java-service-role/
│   |   ├── .kitchen.yml
│   |   └── ...
│   └── nginx-webserver-role/
│       ├── .kitchen.yml
│       └── ...
└── site.yml
```

This project aims at reducing the duplication between the `.kitchen.yml` files
and improving the maintainability of more complex infrastructure projects.

## Getting Started

Being only a simple extension to Test Kitchen, you should start with the
guides there.  See the [Test Kitchen README][kitchen-readme] to get started
and to get your tests running without this extension.

[kitchen-readme]: https://github.com/test-kitchen/test-kitchen

## Usage

This can be run in all the same ways as Test Kitchen, just using the command
`kitchen-pc` instead of `kitchen`.

If you're using RubyGem to manage your gems:

```bash
# Install the gem by name
gem install test-kitchen-pc

# Run kitchen-pc the same way you run kitchen
kitchen-pc converge default-centos-6
```

Optionally, you can use [Bundler](http://bundler.io/) to manage the gem by
adding `gem "test-kitchen-pc"` to your `Gemfile`, then:

```bash
# Install the deps from the Gemspec
bundle install

# Run kitchen-pc the same way you run kitchen
bundle exec kitchen-pc converge default-centos-6
```

## Configuration

To support inheritance, this extensions adds support for the top-level
`parent` paremeter in any of the `.kitchen.yml` files that Test Kitchen
is configured to read normally.

Let's say you have a project `.kitchen.yml` that defines a set of pretty
generic settings for testing:

**`.kitchen.parent.yml`**

```yaml
---
driver:
  name: docker

provisioner:
  name: ansible_playbook
  ansible_inventory: test/integration/inventory/hosts
  roles_path: ../

platforms:
  - name: centos-6
  - name: centos-7

suites:
  - name: default
```

The majority of this configuration will be the same across all of the
infrastructure modules that you're testing.  Using this extension, you
can export all common configuration to a shared file, and then source
the shared configuration using the `parent` parameter, then inline any
customizations you may need to make.

For example, say we wanted to export the above as common configuration,
but then have a role that needs to define some host aliases in the
Docker driver:

**`roles/sample-role/.kitchen.yml`**

```yaml
---
parent: ../../.kitchen.parent.yml

driver:
  name: docker
  run_options:
    add-host:
      - "sample-host:127.0.0.1"
```

This will result in the `roles/sample-role/.kitchen.yml` config being merged
into the `.kitchen.parent.yml` file, with the former overriding and properties
that are specified in both.


## Development

If you'd like to contribute, feel free to open a PR.  To run the tests prior
to submitting the PR, just clone the project and run the integration tests:

```
# Install deps
bundle install

# Run integration tests
bundle exec kitchen-pc test
```



