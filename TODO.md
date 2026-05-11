# TODO

Future improvements to `nrk8s-diag.sh`.

## eBPF Agent

- [ ] **Kernel prerequisite checks** — kernel version (>= 4.14, ideally 5.x+), BTF availability (`/sys/kernel/btf/vmlinux`), required kernel config flags (`CONFIG_BPF`, `CONFIG_BPF_SYSCALL`, `CONFIG_BPF_JIT`) per node
- [ ] **eBPF agent pod/daemonset diagnostics** — detect eBPF agent workloads by label/name, verify pod security context and required capabilities (`CAP_BPF`, `CAP_SYS_ADMIN`, `CAP_SYS_PTRACE`), collect logs filtered for probe load/attach failures, describe eBPF CRDs and events

## Pipeline Control Gateway (PCG)

- [ ] **PCG diagnostic mode (`-g` flag)** — detect PCG Helm release, collect pod logs and workload descriptions, capture CRDs and custom resources (pipeline rules, routing config), output to numbered archive files
- [ ] **PCG connectivity and pipeline routing checks** — verify PCG → NR ingest endpoint reachability (otlp, metric, log, trace), upstream collector connectivity, capture pipeline rule CRs in YAML, validate TLS and service/ingress config

## Performance

- [x] **Parallelize pod log retrieval** — background each pod's log collection into a temp file (same pattern as describe phase), then merge; biggest remaining sequential bottleneck after describe
- [ ] **Parallelize connectivity checks** — run all 4 `kubectl run` endpoint probes concurrently with `&` / `wait` instead of sequentially
- [ ] **Cache `kubectl api-resources`** — result is fetched twice (kube describe phase + pixie resources); compute once at startup and reuse

## General

- [ ] **Auto-detection of installed components** — scan for eBPF agent, PCG, and Pixie presence at startup and auto-enable relevant diagnostic sections; print detected components summary before collecting; expose as `--auto` flag or make default when no mode flags are given
- [ ] **Wire up new flags into script** — add `-e` (eBPF) and `-g` (PCG) to `getopts` and `usage()`, update startup summary block, update README with new flags and collected data descriptions
