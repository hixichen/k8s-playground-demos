package kubernetes.admission  

import data.kubernetes.namespaces  
  
deny[msg] {  
    input.request.kind.kind = "Deployment"  
    input.request.operation = "CREATE"  
    registry = input.request.object.spec.template.spec.containers[_].image  
    name = input.request.object.metadata.name  
    namespace = input.request.object.metadata.namespace  
    not reg_matches_any(registry,valid_deployment_registries)  
    msg = sprintf("invalid deployment, namespace=%q, name=%q, registry=%q", [namespace,name,registry])  
}  
  
valid_deployment_registries = {registry |  
    whitelist = "ecr,docker,mytest"  
    registries = split(whitelist, ",")  
    registry = registries[_]  
}  
  
reg_matches_any(str, patterns) {  
    reg_matches(str, patterns[_])  
}  
  
reg_matches(str, pattern) {  
    contains(str, pattern)  
}