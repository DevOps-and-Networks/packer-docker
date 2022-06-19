import pyodbc
import os
from datetime import date
import boto3

env_list=['sit2','sit3','sit4','sit5','sit6','sit7','sit8','sit9','sit11']
region="ap-southeast-2"
ACCOUNT_ID="862017364710"
def find_pod_name(environment):
    global pod_name
    pod_name=(os.popen('AWS_ACCESS_KEY_ID='+ACCESS_KEY+' AWS_SECRET_ACCESS_KEY='+SECRET_KEY+' AWS_SESSION_TOKEN='+SESSION_TOKEN+" kubectl get pods -n "+environment+"-rnl | grep mssql | awk '{print $1}'")).read().strip()
    print (pod_name)
    find_mssql_password(pod_name,environment)

def find_mssql_password(pod_name,environment):
    global sql_password
    sql_password=(os.popen('AWS_ACCESS_KEY_ID='+ACCESS_KEY+' AWS_SECRET_ACCESS_KEY='+SECRET_KEY+' AWS_SESSION_TOKEN='+SESSION_TOKEN+' kubectl exec -it '+pod_name+' -n '+environment+'-rnl -- printenv MSSQL_SA_PASSWORD')).read().strip()
    print(sql_password)

def run_query(username,db_password,server,backup_command,database):
    cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ str(db_password))
    cnxn.autocommit = True
    cursor = cnxn.cursor()
    cursor.execute(str(backup_command))
    while (cursor.nextset()):
        pass
    cnxn.commit()
    cnxn.close()

def copy_bakup_to_s3(environment,s3_path,file_name):
    # print('os.system(aws s3 cp /var/opt/mssql/data/'+file_name+' '+s3_path )  sit11_master_2022-06-16.bak
    os.system('AWS_ACCESS_KEY_ID='+ACCESS_KEY+' AWS_SECRET_ACCESS_KEY='+SECRET_KEY+' AWS_SESSION_TOKEN='+SESSION_TOKEN+' kubectl exec -it '+pod_name+' -n '+environment+'-rnl -- aws s3 cp /var/opt/mssql/data/'+file_name+' '+s3_path )


def assume_role(ACCOUNT_ID):
    print("assuming role for "+ACCOUNT_ID)
    sts_client = boto3.client('sts')
    aws_role_info = sts_client.assume_role(
        RoleArn="arn:aws:iam::"+str(ACCOUNT_ID)+":role/CrossAccount-PlatformAdmins",
        RoleSessionName="cross-account-role"
    )
    globals()['ACCESS_KEY'] = aws_role_info['Credentials']['AccessKeyId']
    globals()['SECRET_KEY'] = aws_role_info['Credentials']['SecretAccessKey']
    globals()['SESSION_TOKEN'] = aws_role_info['Credentials']['SessionToken']

def db_s3_backup(ACCESS_KEY,SECRET_KEY,SESSION_TOKEN):
    for items in env_list:

        print( 'Now taking backup for '+items)
        # print('os.system(AWS_ACCESS_KEY_ID='+ACCESS_KEY+' AWS_SECRET_ACCESS_KEY='+SECRET_KEY+'AWS_SESSION_TOKEN='+SESSION_TOKEN+'  aws eks --region '+region+' update-kubeconfig --name '+items.upper()+'-EKS-Cluster')
        os.system('AWS_ACCESS_KEY_ID='+ACCESS_KEY+' AWS_SECRET_ACCESS_KEY='+SECRET_KEY+' AWS_SESSION_TOKEN='+SESSION_TOKEN+'  aws eks --region '+region+' update-kubeconfig --name '+items.upper()+'-EKS-Cluster')
        today = date.today()
        environment = items
        database="master"
        server="sql-"+str(environment)+".vicroads.vic.gov.au"
        username = 'sa'
        backup_command= "BACKUP DATABASE ["+database+"] TO DISK = N'"+environment+"_"+database+"_"+str(today)+".bak'"
        file_name=environment+"_"+database+"_"+str(today)+".bak"
        s3_path="s3://vrinstallfiles/SQL-WEB/"+environment+"/"+file_name
        pod_name=""
        find_pod_name(environment)
        run_query(username,sql_password,server,backup_command,database)
        copy_bakup_to_s3(environment,s3_path,file_name)

assume_role(ACCOUNT_ID)
db_s3_backup(ACCESS_KEY,SECRET_KEY,SESSION_TOKEN)
