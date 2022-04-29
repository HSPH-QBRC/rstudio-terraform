### Terraform-based RStudio setup

This repository contains files and helper scripts which will setup a RStudio server on a GCP VM.

#### Instructions
- Install [git](https://git-scm.com), [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) and [Terraform](https://www.terraform.io/downloads.html)
- Clone this repository
- Create a service account key file using the GCP console or via command line. This service account file should have privileges to create networks and VMs. The easiest is probably to assign it "editor" privileges. Download the resulting JSON-format file to your cloned directory.
    - To do this via commandline, run: 
```
gcloud iam service-accounts create <NAME> --display-name="<SOME NAME>"
gcloud projects add-iam-policy-binding <GCP project name> \ 
    --member='serviceAccount:<NAME>@<GCP project name>.iam.gserviceaccount.com' \ 
    --role='roles/editor'
gcloud iam service-accounts keys create key.json --iam-account=<NAME>@<GCP project name>.iam.gserviceaccount.com
```
where `<NAME>` is the name of your service account (which has some regex-based restrictions, so keep it simple) and `<GCP project name>` is the *name* of your GCP project (not the numerical ID).

Running those commands will download a file named `key.json` to your current working directory. BE CAREFUL WITH THAT KEY!! The `.gitignore` will ignore "*.json" files, which is hopefully enough of a barrier to prevent accidental commits.

- Copy the terraform variable template file: `cp terraform.tfvars.tmpl terraform.tfvars` and fill-in the variables. The `credentials_file` variable is the name of the JSON-format service account key file you just created/downloaded.
- `terraform init`
- `terraform apply`

This will create the VM and report the IP address to your terminal. Once the installation scripts are complete, you should be able to access a RStudio instance at `http://<IP ADDRESS>/`

Note that visting that address will prompt for a login. As set up, the RStuio instance uses the username/password of user accounts on the VM itself. If you wish to login to RStudio, it's probably best to create a "basic" user for yourself, as described below.

#### Creating users

The repository also comes with a helper script (`add_users.sh`). This allows us to add new system users (which effectively creates a login for RStudio) and to copy any common files that might need to be shared with all course participants. The script assumes the data is located in `/home/common_data`. If there is no common data to share, then the copy commands will just fail.

To run the script, you first have to SSH to the machine. Then, create a basic text file where each line has 3 elements delimited by a comma:
- email address
- a username (needs to be Unix valid!)
- a plain text password

Be careful not to put spaces in there, as it's a pretty brittle script. e.g. the file should look like:

```
foo@email.com,foo-user,abc123
bar@email.com,someone-else,def456
```

The `add_users.sh` takes this file as its first and only argument. It then iterates through each line, creating users, home directories, and copying any files.

The usernames and passwords in that file can then be used to log into RStudio. Each user will have their own workspace with copies of the necessary files.