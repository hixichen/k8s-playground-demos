# setup gatekeeper in minikube
./seteup.sh

# check the log of gatekeeper
`kubectl logs -f gatekeeper-controller-manager-0 -n gatekeeper-system`

# test the contraint
- Test with illegal image repo

    `kubectl apply -f test.yaml`
    It should not get any pod. Instead, try:   
        `kubectl get replicaset`
    Then, descibe the replicaset:    
        `kubectl describe replicaset test-xxx`
    the msg: 
`Warning  FailedCreate      10m (x16 over 13m)  replicaset-controller  Error creating: admission webhook "validation.gatekeeper.sh" denied the request: container <test> has an invalid image repo <busybox>, allowed repos are ["test", "ecr"]`


- add image repo to contraint yaml
  Try to add 'busybox' to allow-repo.yaml, then:
  `kubectl apply -f allow-repo.yaml`

   After for a while, it should be a test pod running via `kubectl get po`
   log:
   `
      test-cc57dd6f-c47x6   1/1     Running   0          12m
    `
