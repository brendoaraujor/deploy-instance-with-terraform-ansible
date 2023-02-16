# Deploy de instâncias EC2 utilizando Terraform e Ansible

Neste projeto, estamos criando uma instância com um servidor web executando um site estático através do IP publico da EC2 na porta 80.

## Compilação

Primeiro execute aws configure e faça login com sua acess key e secret key.

Gere uma key ssh com ssh-keygen e adicione o valor da chave publica no arquivo vars.tf e o path da key privada em main.tf

Comando Terraform:

terraform apply –auto-approve

Execute ansible para configurar o webserver.

ansible-playbook ansible/deploy_webserver.yml -i ansible/hosts

Por fim:

terraform destroy
