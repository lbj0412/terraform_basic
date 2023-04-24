# Terraform Basics
## GCP에서 배우는 Terraform 기본과정 Sample 코드 저장소입니다. 

### 구성환경
- Terraform 버전 : 1.4.5
- gcloud install
- gcloud auth application-default login
---

### Module 3 Terraform GCP Resource Deploy
- 목표 :  
    1. Terraform의 기본 명령어를 배웁니다.
    2. 변수 사용, output, count, startup_script를 사용하는 법을 배웁니다.
    3. GCP에서 아래 리소스를 직접 생성해 봅니다. 
        - VPC
        - Subnet
        - instance
---

### Module 4 Web serivce on GCP
- 목표 :
    1. 다음 구성도를 바탕으로 GCP 리소스를 배포합니다.
    ![image](./module_4_web_service_on_gcp/docs/image/architecture.png)
    2. 각 리소스를 생성하는 Terraform code를 [resource].tf 명으로 생성하였습니다. 
    3. Module 4에 대한 상세한 설명은 [README.md](./module_4_web_service_on_gcp/README.md)를 참고해 주세요.

---
### Module 5 Module_on_GCP
- 목표 :
    1. Module을 사용하는 방법을 배웁니다.
    2. Module에서 for_each를 사용하는 법을 배웁니다. 
    3. 외부 Module을 사용하는 법을 배웁니다.
    4. Module을 사용하여 Module 4의 리소스를 생성합니다.