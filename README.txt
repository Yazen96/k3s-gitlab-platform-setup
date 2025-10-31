
## README.txt

## Setup instructions for GitLab and GitLab Runner on K3s

1. Make sure you are inside the folder "sofa".
   Example:
   cd ~/sofa

2. Create and open the setup script file:
   nano setup-essentials.sh

3. Paste the script content that installs K3s, Helm, kubectl, Terraform, and namespaces.
   Save it with CTRL + O, press Enter, then exit with CTRL + X.

4. Make the script executable:
   chmod +x setup-essentials.sh

5. Run the setup script:
   sudo ./setup-essentials.sh

   This will:

   * Install K3s, Helm, kubectl, and Terraform if missing
   * Configure kubeconfig
   * Add Helm repositories for GitLab
   * Create namespaces “gitlab” and “gitlab-runner”

6. When the script finishes, check that everything works:
   kubectl get nodes
   helm repo list
   kubectl get ns

   You should see the namespaces “gitlab” and “gitlab-runner” listed.

7. To install GitLab, run:
   helm upgrade --install gitlab gitlab/gitlab 
   -n gitlab 
   -f infrastructure/helm-values/gitlab-values-traefik.yaml

8. To install GitLab Runner, run:
   helm upgrade --install gitlab-runner gitlab/gitlab-runner 
   -n gitlab-runner 
   -f infrastructure/helm-values/gitlab-runner-values-traefik.yaml

9. To verify that the pods are running, use:
   kubectl get pods -A

   Wait until all GitLab and gitlab-runner pods show “Running”.

10. To access GitLab in your browser, open:
    [http://gitlab.local](http://gitlab.local)

    (Make sure your host file or DNS points gitlab.local to the VM IP address, for example 10.132.40.4)

---

Notes:

* You only need to run the setup script once per VM.
* The Helm install commands can be re-run safely; Helm will upgrade existing releases.
* The GitLab Runner should register automatically in GitLab under “Admin → Runners”.
