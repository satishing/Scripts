#!/usr/bin/env bash
SCRIPTDIR=$(dirname $0)

if [ -f ${SCRIPTDIR}/azure_config ]
then
    source ${SCRIPTDIR}/azure_config
else
    echo "Config file not found in ${SUBSCRIPTION_ID} directory"
    exit
fi

### Create Resource group if not present. Uncomment/Comment below as required
az group create --name ${RESOURCE_GROUP} --location ${LOCATION} --tags ${TAGS}

### Create VNET and subnets if not present, Uncomment/Comment below as required
az network vnet create --name ${VNET_NAME} \
                       --resource-group ${RESOURCE_GROUP} \
                       --location ${LOCATION} \
                       --address-prefixes ${VNET_CIDR} \
                       --subnet-name ${SUBNET_NAME} \
                       --subnet-prefixes ${SUBNET_PREFIXES} \
                       --subscription ${SUBSCRIPTION_ID}\
                       --tags ${TAGS}
                       #--ddos-protection {false, true} \
                       #--ddos-protection-plan \
                       #--defer \
                       #--dns-servers \
                       #--vm-protection

SUBNET_ID=$(az network vnet subnet show --resource-group ${RESOURCE_GROUP} --vnet-name ${VNET_NAME} --name ${SUBNET_NAME} --query id | tr -d '"')

### Create LA workspace if not present, Uncomment/Comment below as required
az monitor log-analytics workspace create --resource-group ${RESOURCE_GROUP} \
                                          --workspace-name ${LA_WORKSPACE_NAME} \
                                          --location ${LOCATION} \
                                          --tags ${TAGS} \
                                          --retention-time \
                                          --subscription \

LA_WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group ${RESOURCE_GROUP} --workspace-name ${LA_WORKSPACE_NAME} --query id | tr -d '"') 2>/dev/null

### Create AKS Cluster
if [[ -z ${RESOURCE_GROUP} && -z ${AKS_NAME} ]]
then
    echo "Either RESOURCE_GROUP or AKS_NAME not set"
    exit
fi

az aks create --name ${AKS_NAME} \
              --resource-group ${RESOURCE_GROUP} \
              --location ${LOCATION} \
              --kubernetes-version ${KUBERNETES_VERSION} \
              --node-count ${NODE_COUNT} \
              --min-count ${MIN_NODE_COUNT} \
              --max-count ${MAX_NODE_COUNT} \
              --node-vm-size ${VM_SIZE} \
              --nodepool-name ${NODE_POOL_NAME} \
              --vm-set-type ${VM_SET_TYPE} \
              --zones ${ZONES} \
              --vnet-subnet-id ${SUBNET_ID} \
              --dns-service-ip ${DNS_SERVICE_IP} \
              --service-cidr ${SERVICE_CIDR} \
              --docker-bridge-address ${DOCKER_BRIDGE_CIDR} \
              --network-plugin ${NETWORK_PLUGIN} \
              --network-policy ${NETWORK_POLICY} \
              --subscription ${SUBSCRIPTION_ID} \
              --aad-tenant-id ${TENANT_ID} \
              --enable-addons ${ENABLE_ADDONS} \
              --workspace-resource-id ${LA_WORKSPACE_ID} \
              --tags ${TAGS} \
              --enable-cluster-autoscaler \
              --generate-ssh-keys \
              --aad-client-app-id ${AAD_CLIENT_APP_ID} \
              --aad-server-app-id ${AAD_SERVER_APP_ID} \
              --aad-server-app-secret ${AAD_SERVER_APP_SECRET} \
              --service-principal ${CLIENT_ID} \
              --client-secret ${CLIENT_SECRET}
              #--enable-rbac \
              #--admin-username  \
              #--api-server-authorized-ip-ranges  \
              #--attach-acr  \
              #--disable-rbac \
              #--dns-name-prefix   \
              #--load-balancer-idle-timeout  \
              #--load-balancer-managed-outbound-ip-count  \
              #--load-balancer-outbound-ip-prefixes  \
              #--load-balancer-outbound-ips  \
              #--load-balancer-outbound-ports  \
              #--load-balancer-sku
              #--pod-cidr  \
              #--max-pods  \
              #--no-ssh-key  \
              #--no-wait  \
              #--node-osdisk-size  \
              #--skip-subnet-role-assignment  \
              #--ssh-key-value  \





