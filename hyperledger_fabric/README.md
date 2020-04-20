
Hello there. I’m an engineer from [VMware Kubernetes Engine](https://blogs.vmware.com/cloudnative/2018/06/26/introducing-vmware-kubernetes-engine-vke/).


This article describes the way to deploy fabric on kubernetes which is provided by VMware Kubernetes Engine. 
And describes the issues I have and how to solve them.


### 0. Hyperledge Fabric and blockchain

[Blockchain](https://en.wikipedia.org/wiki/Blockchain)  
[Blockchain Technology](https://blockgeeks.com/guides/what-is-blockchain-technology)  

**What is Hyperledger Fabric?**  
The Linux Foundation founded the Hyperledger project in 2015 to advance cross-industry blockchain technologies. Rather than declaring a single blockchain standard, it encourages a collaborative approach to developing blockchain technologies via a community process, with intellectual property rights that encourage open development and the adoption of key standards over time.

Hyperledger Fabric is one of the blockchain projects within Hyperledger. Like other blockchain technologies, it has a ledger, uses smart contracts, and is a system by which participants manage their transactions.

Where Hyperledger Fabric breaks from some other blockchain systems is that it is private and permissioned. Rather than an open permissionless system that allows unknown identities to participate in the network (requiring protocols like “proof of work” to validate transactions and secure the network), the members of a Hyperledger Fabric network enroll through a trusted Membership Service Provider (MSP).

Hyperledger Fabric also offers several pluggable options. Ledger data can be stored in multiple formats, consensus mechanisms can be swapped in and out, and different MSPs are supported.

Hyperledger Fabric also offers the ability to create channels, allowing a group of participants to create a separate ledger of transactions. This is an especially important option for networks where some participants might be competitors and not want every transaction they make — a special price they’re offering to some participants and not others, for example — known to every participant. If two participants form a channel, then those participants — and no others — have copies of the ledger for that channel.

**Use Cases:**  

- Business-to-business (B2B) contract: This technology can be used to automate business contracts in a trusted way.

- Asset depository: Assets can be dematerialized on a blockchain network, making it possible for all for all stakeholders of an asset type to have access to each asset without going through intermediaries or middlemen. Currently, assets are tracked in many ledgers, which must reconcile. Hyperledger Fabric replaces these multiple ledgers with a single decentralized ledger, providing transparency and removing intermediaries.

- Loyalty: A loyalty rewards platform can be securely built on top of blockchain (for this case, Hyperledger Fabric) and smart contracts technology.

- Distributed storage to increase trust between parties.

**Companies:**  

- Alibaba cloud: 

https://www.alibabacloud.com/blog/developing-blockchain-applications-based-on-hyperledger-fabric-with-alibaba-cloud-container-service-blockchain-solution_593950

- Microsoft Azure:  
  https://azuremarketplace.microsoft.com/fi/marketplace/apps/microsoft-azure-blockchain.azure-blockchain-hyperledger-fabric?tab=Overview

- IBM Cloud:  
  https://www.ibm.com/blockchain/hyperledger

### 1. Get Kubernetes cluster

    It is super easy to get a kubernetes cluter via VKE.
    
    Just several click and use VKE cli to merge the kubectl auth, then you are good to go. 
    
    Try [VKE](https://cloud.vmware.com/vmware-kubernetes-engine)


### 2. Setup NFS Server On Kubernte Cluster
    ```
    # Go to your Linux/Mac terminal

    $kubectl apply -f nfs-deployment.yaml
    # need to run as priviledge pod.
    ```
    

After the pod is running. try to deploy "nfs-jump.yaml" to a test.

**What if my jumpbox is keep pending?**  
    [Mount Failure with exit status 32](https://github.com/hixichen/hyperledger_fabric_on_kubernetes/issues/1)
    

### 3. Gegereate the Certificate Via JumpBox Pod
- **why we need a Jumpbox machine?**

    * It is hard to debug privilege pod.
    * NFS needs pre created mount point before pods can use nfs as shared storage.
    * We need to generate the cerficate before deployment. 
      Fabric depends on the NFS to share the certs and configuration.
      [refer: hyperledger-fabric certs configruation](http://www.think-foundry.com/deploy-hyperledger-fabric-on-kubernetes-part-1/)
    
      Since NFS is shared storage, a Jumpbox is the easiest way to create the mount point, certs and configurations.
      
    ```

    # Go to your Linux/Mac terminal

    $kubectl apply -f nfs-jump.yaml

    #after the pod is running. 

    $kubectl exec -it nfs-jump-9285c  /bin/bash

    ## The command always in a programer's mind with a new ubuntu image:
    $ apt-get update && apt-get install -y vim wget

    ## the jumpbox pods will mount /exports to /mnt directory. 
    ## any files on /mnt will shared on NFS server.

    ```
- **Generate certificate**

    Go to your Linux/Mac terminal
    download the "crypto-gen":
    ```
    wget https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/linux-amd64-1.0.5/hyperledger-fabric-linux-amd64-1.0.5.tar.gz
    ```
    You will get a "/bin" directory with all the tools binary.
    

    **quick go through crypto-config.yaml:**
    
    I spend whole afternoon to debug the mount failure issue. 
    It turns out that I forget to add the hostname. The helm template will use index to find the certificate path. 
    It is worth noting that specify the hostname with index is important.
        
    ```
        
    OrdererOrgs:
      - Name: orderer
        Domain: orderer.com
        Specs:
          - Hostname: orderer0
    ```
    
    
    **generate certificate from Jumpbox**

    ```
    # copy crypo-config.yaml to jumpbox
    $kubectl cp cryptogen nfs-jump-9285c:/mnt
    
    # copy crypo-config.yaml to jumpbox
    $kubectl cp crypo-config.yaml nfs-jump-9285c:/mnt
    
    # go to jumpbox
    $kubectl exec -it nfs-jump-9285c  /bin/bash
    
    # create cerficate
    ./cryptogen generate --config=./crypto-config.yaml

    ```
    **You will get:**

    ```
    root@nfs-jump-9285c:/# tree -L 4 crypto-config
    crypto-config
    |-- ordererOrganizations
    |   `-- orderer.com
    |       |-- ca
    |       |   |-- b5b3e16c6eddbea98a13fb2a8b39b274bd13872a979a911f2558839e179c4414_sk
    |       |   `-- ca.orderer.com-cert.pem
    |       |-- msp
    |       |   |-- admincerts
    |       |   |-- cacerts
    |       |   `-- tlscacerts
    |       |-- orderers
    |       |   `-- orderer0.orderer.com
    |       |-- tlsca
    |       |   |-- 03b9f52323400c0c23d5a396deb7465f3d14acf0d0a75ba90a8696493fa3ebc7_sk
    |       |   `-- tlsca.orderer.com-cert.pem
    |       `-- users
    |           `-- Admin@orderer.com
    `-- peerOrganizations
        |-- org1.com
        |   |-- ca
        |   |   |-- ca.org1.com-cert.pem
        |   |   `-- cf26dc8b02c4a5510be39bccff92ad137defff72a39e94b70f8768f4ab2d56a8_sk
        |   |-- msp
        |   |   |-- admincerts
        |   |   |-- cacerts
        |   |   `-- tlscacerts
        |   |-- peers
        |   |   |-- peer0.org1.com
        |   |   `-- peer1.org1.com
        |   |-- tlsca
        |   |   |-- 5f0a301a1ee2a5d36d449987e9fe142bba4aea633b157af5a3e1b35f56de25b3_sk
        |   |   `-- tlsca.org1.com-cert.pem
        |   `-- users
        |       |-- Admin@org1.com
        |       `-- User1@org1.com
        `-- org2.com
            |-- ca
            |   |-- a0bdda015cf64e3937892fd7bbb13e424607c032013eb12e6b4db2f42dc04666_sk
            |   `-- ca.org2.com-cert.pem
            |-- msp
            |   |-- admincerts
            |   |-- cacerts
            |   `-- tlscacerts
            |-- peers
            |   |-- peer0.org2.com
            |   `-- peer1.org2.com
            |-- tlsca
            |   |-- de2df92c7353e1bf89327acf41f04b0325475b230bdaa929a4c04029cfefc9d9_sk
            |   `-- tlsca.org2.com-cert.pem
            `-- users
                |-- Admin@org2.com
                `-- User1@org2.com
    
        39 directories, 12 files

    ```
    
    ```
    # create directory we need
    $mkdir -p /mnt/cluster/resources

    # put the directory into right place
    $mv /mnt/crypto-config /mnt/cluster/resources/
    ```
    
    You are all set with the certificate generate parts.
    


### 4. Deploy Fabric on Kubernetes with Helm
    
[what is helm?](https://helm.sh/) deployment tools to install applications on kubernetes cluster.

- Check the nfs server address:

    ```
    $kubectl get svc
    NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE
    kubernetes   ClusterIP   10.0.0.1     <none>        443/TCP                      2d
    nfs          ClusterIP   10.0.0.229   <none>        2049/TCP,20048/TCP,111/TCP   10h
    ```
    
    **set "10.0.0.229" to  ./fabric/values.yaml**  
    nfs:
      ip: 10.0.0.229

- Deploy fabric blockchain network with helm

    ```
    on your mac/linux
    $helm init --service-account=tiller
    
    make sure that you can see fabric directory with "ls"
    $helm install --name fabric-vke fabric
        

    helm commands:
    helm install --debug --dry-run fabric > x.   ## this is very useful to debug.
    helm del --purge fabric-vke
    helm list --deleted
    helm list
   ```

### 5. Ready to Play

* check the pods are running:  
    $kubectl get pods --all-namespaces

* create private channel and deploy DAPP [TODO]

    use the configtx tool to generate channel-related files to create and join a channel.
