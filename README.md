[![New Relic Experimental header](https://github.com/newrelic/opensource-website/raw/master/src/images/categories/Experimental.png)](https://opensource.newrelic.com/oss-category/#new-relic-experimental)

# Kubernetes Diag Utilities

A repository of utilities related to troubleshooting Kubernetes and Pixie installation issues.

## nrk8s-diag.sh (Unified Script)

`nrk8s-diag.sh` combines both the Kubernetes and Pixie diagnostics into a single script. Use the `-k` and `-p` flags to run one or both diagnostic sets. If neither flag is specified, both are run.

### Usage

Run from a terminal with `kubectl` and (optionally) `helm` access to the cluster. The namespace will typically be `newrelic`.

```bash
# Run all diagnostics (Kubernetes + Pixie)
./nrk8s-diag.sh -n newrelic

# Kubernetes diagnostics only
./nrk8s-diag.sh -n newrelic -k

# Pixie diagnostics only
./nrk8s-diag.sh -n newrelic -p

# Custom Helm release name
./nrk8s-diag.sh -n newrelic -r my-release -k
```

| Flag | Description |
|------|-------------|
| `-n NAMESPACE` | **(Required)** Namespace where New Relic is installed |
| `-r RELEASE_NAME` | *(Optional)* Helm release name (default: `newrelic-bundle`) |
| `-k` | Run Kubernetes diagnostics |
| `-p` | Run Pixie diagnostics |

### Kubernetes Diagnostics (`-k`)

- New Relic endpoint connectivity checks
- Cluster info, nodes, versions, storage classes
- New Relic CRDs and ClusterRoles/ClusterRoleBindings
- Workload status (pods, deployments, daemonsets)
- Full resource descriptions for the namespace
- Pod logs (current and previous)
- Namespace events and network policies
- Helm values and history

### Pixie Diagnostics (`-p`)

- Node memory and count validation (Pixie requires ≥ 8 GB RAM per node)
- Node system info and resource allocations
- Pixie agent status and log collection via `px` CLI (if available)
- Namespaced resource listing across `olm`, `px-operator`, and the target namespace
- Deployment logs for Pixie-related workloads
- Per-pod event collection

If you have the `px` CLI installed, authenticate before running:

```bash
px auth login
px run px/cluster
```

### Output

A compressed archive named `nrk8s_diag_<timestamp>.tar.gz` containing numbered log files for each diagnostic section. Attach this file to your New Relic support ticket.

---

## Individual Scripts (Legacy)

The original standalone scripts are still available:

- `kube-diag/nrk8s-diag.sh` — Kubernetes-only diagnostics
- `pixie-diag/pixie-diag` — Pixie-only diagnostics

See the README in each subdirectory for usage details.

---

## Support

New Relic has open-sourced this project. This project is provided AS-IS WITHOUT WARRANTY OR DEDICATED SUPPORT. Issues and contributions should be reported to the project here on GitHub.

>We encourage you to bring your experiences and questions to the [Explorers Hub](https://discuss.newrelic.com) where our community members collaborate on solutions and new ideas.


## Contributing

We encourage your contributions to improve `k8s-diag-utilities`! Keep in mind when you submit your pull request, you'll need to sign the CLA via the click-through using CLA-Assistant. You only have to sign the CLA one time per project. If you have any questions, or to execute our corporate CLA, required if your contribution is on behalf of a company, please drop us an email at opensource@newrelic.com.

**A note about vulnerabilities**

As noted in our [security policy](../../security/policy), New Relic is committed to the privacy and security of our customers and their data. We believe that providing coordinated disclosure by security researchers and engaging with the security community are important means to achieve our security goals.

If you believe you have found a security vulnerability in this project or any of New Relic's products or websites, we welcome and greatly appreciate you reporting it to New Relic through [HackerOne](https://hackerone.com/newrelic).

## License

`k8s-diag-utilities` is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.

>[If applicable: [Project Name] also uses source code from third-party libraries. You can find full details on which libraries are used and the terms under which they are licensed in the third-party notices document.]
