# How to generate the default CA:
cfssl gencert -initca config/ca-csr.json | cfssljson -bare default-ca
