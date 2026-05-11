#!/usr/bin/env bats
# Tests for nrk8s-diag.sh
# Run with: ./run_tests.sh  (requires bats-core)

SCRIPT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/nrk8s-diag.sh"
MOCKS_DIR="${BATS_TEST_DIRNAME}/mocks"

setup() {
    export PATH="${MOCKS_DIR}:${PATH}"
    export MOCK_NS_VALID="newrelic"
    # Run from a temp dir so archives don't land in the project root
    cd "${BATS_TEST_TMPDIR}"
}

teardown() {
    rm -f "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz
}

# ── Argument parsing ───────────────────────────────────────────────────────────

@test "exits 1 and shows usage when -n is missing" {
    run bash "${SCRIPT}"
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "Usage:" ]]
}

@test "exits 1 and shows usage for unknown flag" {
    run bash "${SCRIPT}" -z
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "Usage:" ]]
}

@test "exits 1 and shows error when -n value is empty" {
    run bash "${SCRIPT}" -n "" -k
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "Usage:" ]]
}

@test "default helm release name is newrelic-bundle" {
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "newrelic-bundle" ]]
}

@test "-r overrides the helm release name" {
    run bash "${SCRIPT}" -n newrelic -r my-custom-release -k
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "my-custom-release" ]]
}

@test "startup summary shows namespace" {
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "newrelic" ]]
}

# ── Diagnostic mode selection ──────────────────────────────────────────────────

@test "no mode flags runs both kube and pixie diagnostics" {
    run bash "${SCRIPT}" -n newrelic
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "Kubernetes Diagnostics" ]]
    [[ "${output}" =~ "Pixie Diagnostics" ]]
}

@test "-k runs only Kubernetes diagnostics" {
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "Kubernetes Diagnostics" ]]
    ! [[ "${output}" =~ "Pixie Diagnostics" ]]
}

@test "-p runs only Pixie diagnostics" {
    run bash "${SCRIPT}" -n newrelic -p
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "Pixie Diagnostics" ]]
    ! [[ "${output}" =~ "Kubernetes Diagnostics" ]]
}

@test "-k and -p together runs both diagnostics" {
    run bash "${SCRIPT}" -n newrelic -k -p
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "Kubernetes Diagnostics" ]]
    [[ "${output}" =~ "Pixie Diagnostics" ]]
}

# ── Namespace validation ───────────────────────────────────────────────────────

@test "exits 1 when namespace does not exist" {
    export MOCK_NS_VALID="other-ns"
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "not a valid namespace" ]]
}

@test "exits 0 when namespace exists" {
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 0 ]
}

@test "invalid namespace output lists valid namespaces" {
    export MOCK_NS_VALID="other-ns"
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 1 ]
    [[ "${output}" =~ "Valid namespaces" ]]
}

# ── Archive creation ───────────────────────────────────────────────────────────

@test "kube mode creates a tar.gz archive" {
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 0 ]
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    [ -n "${archive}" ]
}

@test "pixie mode creates a tar.gz archive" {
    run bash "${SCRIPT}" -n newrelic -p
    [ "${status}" -eq 0 ]
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    [ -n "${archive}" ]
}

@test "archive name contains timestamp" {
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 0 ]
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    [[ "${archive}" =~ nrk8s_diag_[0-9]{14}\.tar\.gz ]]
}

@test "output reports the archive path" {
    run bash "${SCRIPT}" -n newrelic -k
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "nrk8s_diag_" ]]
    [[ "${output}" =~ ".tar.gz" ]]
}

# ── Archive contents ───────────────────────────────────────────────────────────

@test "kube archive contains cluster info file" {
    run bash "${SCRIPT}" -n newrelic -k
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    local contents
    contents=$(tar -tzf "${archive}")
    [[ "${contents}" =~ "01_cluster_info.log" ]]
}

@test "kube archive contains pod logs file" {
    run bash "${SCRIPT}" -n newrelic -k
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    local contents
    contents=$(tar -tzf "${archive}")
    [[ "${contents}" =~ "04_nrk8s_logs.log" ]]
}

@test "kube archive contains helm values file" {
    run bash "${SCRIPT}" -n newrelic -k
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    local contents
    contents=$(tar -tzf "${archive}")
    [[ "${contents}" =~ "06_helm_values.yaml" ]]
}

@test "pixie archive contains key info file" {
    run bash "${SCRIPT}" -n newrelic -p
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    local contents
    contents=$(tar -tzf "${archive}")
    [[ "${contents}" =~ "11_pixie_key_info.log" ]]
}

@test "pixie archive contains node info file" {
    run bash "${SCRIPT}" -n newrelic -p
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    local contents
    contents=$(tar -tzf "${archive}")
    [[ "${contents}" =~ "12_pixie_node_info.log" ]]
}

@test "combined archive contains both kube and pixie files" {
    run bash "${SCRIPT}" -n newrelic -k -p
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    local contents
    contents=$(tar -tzf "${archive}")
    [[ "${contents}" =~ "01_cluster_info.log" ]]
    [[ "${contents}" =~ "11_pixie_key_info.log" ]]
}

@test "kube archive does not contain pixie files when -k only" {
    run bash "${SCRIPT}" -n newrelic -k
    local archive
    archive=$(ls "${BATS_TEST_TMPDIR}"/nrk8s_diag_*.tar.gz 2>/dev/null | head -1)
    local contents
    contents=$(tar -tzf "${archive}")
    ! [[ "${contents}" =~ "11_pixie_key_info.log" ]]
}

# ── px CLI availability ────────────────────────────────────────────────────────

@test "pixie diagnostics complete when px CLI is unavailable" {
    # Build a PATH with kubectl and helm mocks but no px
    local no_px_dir="${BATS_TEST_TMPDIR}/mocks_no_px"
    mkdir -p "${no_px_dir}"
    ln -sf "${MOCKS_DIR}/kubectl" "${no_px_dir}/kubectl"
    ln -sf "${MOCKS_DIR}/helm"    "${no_px_dir}/helm"
    local clean_path
    clean_path=$(printf '%s' "${PATH}" | tr ':' '\n' | grep -v "^${MOCKS_DIR}$" | tr '\n' ':')
    export PATH="${no_px_dir}:${clean_path}"

    run bash "${SCRIPT}" -n newrelic -p
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "px CLI unavailable" ]]
}

@test "pixie diagnostics show agent status when px CLI is available" {
    run bash "${SCRIPT}" -n newrelic -p
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "Pixie Agent Status" ]]
}
