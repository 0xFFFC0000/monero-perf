name: Bug report
description: Submit a new bug report.
labels: [bug]
body:
  - type: markdown
    attributes:
      value: |
        ## This issue tracker is only for technical issues related to Monero Core.

        * General monero questions and/or support requests should use Monero StackExchange at https://monero.stackexchange.com.
        * For reporting security issues, please read instructions at https://monerocore.org/en/contact/.
        * If the node is "stuck" during sync or giving "block checksum mismatch" errors, please ensure your hardware is stable by running `memtest` and observe CPU temperature with a load-test tool such as `linpack` before creating an issue.

        ----
  - type: checkboxes
    attributes:
      label: Is there an existing issue for this?
      description: Please search to see if an issue already exists for the bug you encountered.
      options:
      - label: I have searched the existing issues
        required: true
  - type: textarea
    id: current-behaviour
    attributes:
      label: Current behaviour
      description: Tell us what went wrong
    validations:
      required: true
  - type: textarea
    id: expected-behaviour
    attributes:
      label: Expected behaviour
      description: Tell us what you expected to happen
    validations:
      required: true
  - type: textarea
    id: reproduction-steps
    attributes:
      label: Steps to reproduce
      description: |
        Tell us how to reproduce your bug. Please attach related screenshots if necessary.
        * Run-time or compile-time configuration options
        * Actions taken
    validations:
      required: true
  - type: textarea
    id: logs
    attributes:
      label: Relevant log output
      description: |
        Please copy and paste any relevant log output or attach a debug log file.

        You can generate debug information via --log-level=4 flag or by taking a look at log files at ~/.bitmonero/

        Please be aware that the debug log might contain personally identifying information.
    validations:
      required: false
  - type: dropdown
    attributes:
      label: How did you obtain Monero Core
      multiple: false
      options:
        - Compiled from source
        - Pre-built binaries
        - Package manager
        - Other
    validations:
      required: true
  - type: input
    id: core-version
    attributes:
      label: What version of Monero Core are you using?
      description: Run `monerod --version` or in Monero-QT use `Help > About Monero`
      placeholder: e.g. v24.0.1 or master@e1bf547
    validations:
      required: true
  - type: input
    id: os
    attributes:
      label: Operating system and version
      placeholder: e.g. "MacOS Ventura 13.2" or "Ubuntu 22.04 LTS"
    validations:
      required: true
  - type: textarea
    id: machine-specs
    attributes:
      label: Machine specifications
      description: |
        What are the specifications of the host machine?
        e.g. OS/CPU and disk type, network connectivity
    validations:
      required: false
