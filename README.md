# Twitter feed microservice CI/CD with GitLab

This repository contains the code for the Twitter feed microservice that you will use during the [Oracle Container Native Application Development workshop](http://oracle.github.io/learning-library/workshops/container-native-development).

This repository was slightly changed from the [original](https://github.com/chipbaber/twitter-feed-oke) to enable you to configure a CI/CD pipeline using GitLab (Self-managed or Gitlab.com), and deploy the microservice to Oracle Cloud Infrastructure - Container Service for Kubernetes (OKE).

GitLab is a very popular web-based DevOps lifecycle tool that provides a git-repository manager, CI/CD and many other features and is available in Community Edition (Open source) or Enterprise Edition (License required).

## Prerequisites

In order to complete the workshop and deploy the microservice you need to have access to:

* Oracle Cloud Infrastructure account with OKE cluster deployed
* Oracle Cloud Infrastructure User Authentication Token
* Oracle Cloud Infrastructure Container Registry (OCIR) access
* GitLab (self-managed, e.g deployed on OCI or sign up for a gitlab.com account)
* GitLab Runners with Kubernetes and/or Docker executors (available as shared runners on gitlab.com and/or you can also provision your own on OCI)
* Docker (for local tests only)

## Create GitLab Project

GitLab allow you to Import a project from any *git* repository at the time you create your project.
In order to create a new Project for the twitter-feed-oke application, follow these steps:

1. Click on New Project button -> Import project -> Import Project from *Repo by URL*
2. Enter Git repository URL: https://github.com/lucassrg/twitter-feed-oke.git

## Create CI/CD Variables

To integrate your CI/CD pipeline with all your infrastructure, you need to prepare your environment and gather some information that should be stored in your project as CI/CD Variables. GitLab allow you to define variables to store individual values (e.g. Strings) or files like SSH keys. These variables can be accessed directly from your pipelines.

### Integration with Oracle Cloud Infrastructure Container Registry (OCIR)

As part of the CI/CD Pipeline, we are going to publish a Docker Image into the OCIR repository. Oracle Cloud Infrastructure Container Registry (OCIR) is an Oracle-managed registry that enables you to store, share, and manage development artifacts like Docker images. You can create a public or private registry and then use the Docker V2 API and/or Docker CLI for pushing and pulling Docker images. You can check the requirements for creating the registry on the [OCI Registry documentation](https://docs.oracle.com/en-us/iaas/Content/Registry/Concepts/registryprerequisites.htm).

To [publish](https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrypushingimagesusingthedockercli.htm) a Docker image to OCI Registry using Docker CLI we need a valid user and an Auth token to authenticate the user. You can store that token and other information on GitLab as variables. 

Notes:

1. If you don't have a repository in the OCI Container Registry, you can create one following the [documentation](https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrycreatingarepository.htm) or when you push the first Docker image through the CI/CD pipeline a new repository will be created automatically for you.
2. If you don't have an Auth Token, you can generate one following the [documentation](https://docs.oracle.com/en-us/iaas/Content/Registry/Tasks/registrygettingauthtoken.htm). Take notes on the token as it is not displayed twice.

### Creating Project CI/CD Variables

Now you can go back to GitLab and create the variables used by your Project during the CI/CD pipeline.

1. Go to `Settings > CI/CD -> Variables -> Expand`
2. Click on `Add Variable` button and add the following variables:

|key|value|type|description|
|--|--|--|--|
|KUBECONFIG|`<Paste the content of the KUBECONFIG file containing a Service Account token associated with a service account user used for CI/CD>`|File|A KUBECONFIG file setup with a K8s Service Account using an Auth Token is required. Follow the instruction [below](#setup-a-kubernetes-service-account-with-auth-token) to setup the kubeconfig|
|OCI_AUTH_TOKEN|`<auth-token>`|Variable| Enter the Auth token previously created. Make sure you follow security best practices to restrict access to your user to a specific registry and services. More details in the [documentation](https://docs.oracle.com/en-us/iaas/Content/Registry/Concepts/registrypolicyrepoaccess.htm). |
|OCI_REGISTRY_ENDPOINT|Use `<region-prefix>`.ocir.io (without `https://`) |Variable|You can check the list of available endpoints in the [documentation](https://docs.oracle.com/en-us/iaas/Content/Registry/Concepts/registryprerequisites.htm#regional-availability). E.g `https://iad.ocir.io`|
|OCI_TENANCY_NAMESPACE|`<tenancy-namespace>`|Variable|You can retrieve the namespace directly from the Container Registry. Go to the OCI Navigation menu `-> Solutions and Platform -> Developer Services -> Container Registry`.|
|OCI_USERNAME|`<username>`|Variable| Enter your OCI username, e.g. `jdoe@acme.com`. If your tenancy is federated with Oracle Identity Cloud Service, use `oracleidentitycloudservice/jdoe@acme.com`.|



### Setup a Kubernetes service account with Auth Token

By default, when you setup [Access](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm) to the OKE Cluster, the [kubeconfig file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) contains an Oracle Cloud Infrastructure CLI command to generate a short-lived, cluster-scoped, user-specific authentication token.  The authentication token generated by the CLI command is appropriate to authenticate individual users accessing the cluster using kubectl and the Kubernetes Dashboard.

However, the generated authentication token is not appropriate to authenticate processes and tools accessing the cluster, such as continuous integration and continuous delivery (CI/CD) tools. To ensure access to the cluster, such tools require long-lived, non-user-specific authentication tokens. One solution is to set up a Kubernetes service account with a token as explained [here](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengaddingserviceaccttoken.htm).

Once you generated the new kubeconfig file, you can export it with the current context using the command below:
```bash
kubectl config view --minify=true --flatten > ~/.kube/cicd-config
```
Finally, copy the content of the `cicd-config` file and set into the `KUBECONFIG` variable on your CICD pipeline.
