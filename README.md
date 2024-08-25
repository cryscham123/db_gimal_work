## 사용법

1. aws 자원 할당

```bash
cd terraform/dev
terraform apply
```

2. 다 완성되면 aws ec2에 ssh로 접근

```bash
ssh -i .ssh/id_rsa ubuntu@<표시되는 ip>
```

3. ec2에서 필요한거 다운

```bash
sudo apt update
sudo apt install -y mysql-client python-is-python3 python3-pip
pip install flask pymysql

git clone https://github.com/cryscham123/db_gimal_work.git work
```

4. rds에 접근해서 script 실행

```bash
export RDS_ENDPOINT=<표시되는 endpoint> RDS_USERNAME=admin RDS_PASSWORD='Rkrenrl12#'
mysql -h $RDS_ENDPOINT -u $RDS_USERNAME -p $RDS_PASSWORD < work/sql/create.sql
mysql -h $RDS_ENDPOINT -u $RDS_USERNAME -p $RDS_PASSWORD < work/sql/auth.sql
mysql -h $RDS_ENDPOINT -u $RDS_USERNAME -p $RDS_PASSWORD < work/sql/insert.sql
```

5. app 실행

```bash
python work/app/index.py
```
