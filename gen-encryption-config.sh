#! /bin/bash

main() {
    ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
    mkdir -p encryption-config
    
    tee encryption-config/encryption-config.yaml <<<"kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}"
}

main