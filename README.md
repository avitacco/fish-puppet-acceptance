# Litmus Fish Shell Function

A convenient fish shell function that wraps common [Puppet Litmus](https://puppetlabs.github.io/litmus/) commands into shorter, more memorable subcommands.

## Overview

This fish function simplifies working with Puppet Litmus by providing intuitive subcommands for common testing workflows. Instead of typing long `pdk bundle exec rake` commands, you can use short commands like `litmus up` or `litmus test`.

## Installation

1. Save the function to your fish functions directory:
   ```sh
   curl -o ~/.config/fish/functions/litmus.fish https://raw.githubusercontent.com/avitacco/fish-puppet-acceptance/main/litmus.fish
   ```

2. Or manually create the file at `~/.config/fish/functions/litmus.fish` and copy the function content.

3. The function will be automatically available in all new fish sessions. To use immediately in your current session:
   ```sh
   source ~/.config/fish/functions/litmus.fish
   ```

## Usage

```
litmus [command] [options]
```

### Setup Commands

| Command | Description |
|---------|-------------|
| `litmus up [target]` | Complete setup: provision nodes, install puppet agent, and install module (defaults to 'default' target) |
| `litmus provision [target]` | Provision nodes only (defaults to 'default' target) |
| `litmus agent [version]` | Install puppet agent (optional specific version) |
| `litmus module` | Install the module under test |

### Test Commands

| Command | Description |
|---------|-------------|
| `litmus test` | Run acceptance tests in parallel |
| `litmus retest` | Reinstall module and run acceptance tests (useful after code changes) |

### Utility Commands

| Command | Description |
|---------|-------------|
| `litmus attach <image>` | Attach to a running container via docker exec |
| `litmus down` | Tear down the test environment |

## Examples

### Complete Setup and Test
```sh
# Set up default environment and run tests
litmus up
litmus test

# Set up specific environment
litmus up docker
litmus up single
```

### Working with Specific Puppet Agent Versions
```sh
# Provision and install specific puppet agent
litmus provision docker
litmus agent 7.24.0
litmus module
```

### Iterative Development
```sh
# After making code changes, reinstall and test
litmus retest

# Or manually
litmus module
litmus test
```

### Debugging with Container Access
```sh
# List available platforms (shown when image not found)
litmus attach invalid

# Attach to specific container
litmus attach ubuntu:22.04
litmus attach centos:stream9
litmus attach debian:12
```

### Cleanup
```sh
# Tear down all provisioned nodes
litmus down
```

## Requirements

- [Fish shell](https://fishshell.com/) 3.0+
- [PDK (Puppet Development Kit)](https://puppet.com/docs/pdk/latest/pdk.html)
- [Puppet Litmus](https://puppetlabs.github.io/litmus/)
- Docker (for container-based testing)
- Ruby (for parsing inventory files in the attach command)

## File Dependencies

The function expects these files in your Puppet module:
- `provision.yaml` - Defines available provisioning targets
- `spec/fixtures/litmus_inventory.yaml` - Created by Litmus after provisioning (used by `attach` command)

## Customization

To modify the function:
1. Edit `~/.config/fish/functions/litmus.fish`
2. Reload in current session: `source ~/.config/fish/functions/litmus.fish`
3. Changes persist automatically in new sessions

## Tips

- The `up` command runs all three setup steps, perfect for initial setup
- Use `retest` for quick iteration during development
- The `attach` command matches against the platform field in the inventory (e.g., `litmusimage/ubuntu:22.04` can be accessed with just `ubuntu:22.04`)
- Target names come from your `provision.yaml` file (common ones: 'default', 'docker', 'single')

## Troubleshooting

**Function not found**: Ensure the file is in `~/.config/fish/functions/` and named `litmus.fish`

**Attach command fails**: Check that:
- Containers are running (`docker ps`)
- `spec/fixtures/litmus_inventory.yaml` exists
- Ruby is installed (needed for YAML parsing)

**Provision target not found**: Check available targets in your `provision.yaml` file

## Contributing

Feel free to open issues or submit pull requests with improvements!

## License

MIT License - See [LICENSE](LICENSE) file for details

## Acknowledgments

Built for use with [Puppet Litmus](https://puppetlabs.github.io/litmus/), an acceptance testing tool for Puppet modules.