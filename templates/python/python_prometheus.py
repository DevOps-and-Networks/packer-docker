import pandas as pd
import filecmp
import os


old_endpoint_file="old_endpoint.yaml"
new_endpoint_file="new_endpoint.yaml"
compare_new="new_compare_endpoint.yaml"
compare_old="old_compare_endpoint.yaml"
string1 = '#Manually Adding the Windwos Servers list'
Windows_port_configuration="port: 9182"
Linux_port_configuration="port: 9100"
String_exist = "unknown"
new_file = open(new_endpoint_file, "a")
new_compare_file= open(compare_new, "a")
old_compare_file= open(compare_old, "a")
line_counter = 0
old_number_of_rows_to_keyword = 0

def update_post_table():
    df = pd.read_csv('raw_output.txt', sep=',')
    new_file.write( "    port: 9100" + '\n' )
    new_file.write( "    protocol: TCP" + '\n' )
    new_file.write( "- addresses:" + '\n' )
    for index, row in df.iterrows():
        gateway1=("  - ip: "+row['INTERNAL-IP'])
        gateway2=("    targetRef:")
        gateway3=("      kind: Node")
        gateway4=("      name: " +row['NAME'])
        new_file.write( gateway1 + '\n' + gateway2 + '\n' + gateway3 + '\n' + gateway4 + '\n' )
    new_file.write("  ports:" + '\n')
    new_file.write("  - name: http-metrics" + '\n')
    new_file.write("    port: 9182" + '\n')
    new_file.write("    protocol: TCP" + '\n')

# this part can be deleted
# as far as
def check_the_file_status():
    old_file_read = open(old_endpoint_file , 'r')
    global String_exist
    readfile = old_file_read.read()
    if Windows_port_configuration in readfile:
        String_exist = True
    else:
        String_exist = False
    old_file_read.close()

def copy_the_source_table():
    line_counter = 0
    if String_exist == False:
        for line in open(old_endpoint_file):
            line_counter = line_counter + 1
            new_file.write(line)
        update_post_table()
    elif String_exist == True:
        for line in open(old_endpoint_file):
            line_counter = line_counter + 1
            if Linux_port_configuration not in line :
                new_file.write(line)
            elif Linux_port_configuration in line:
                    global old_number_of_rows_to_keyword
                    old_number_of_rows_to_keyword = line_counter + 2
                    update_post_table()
                    break

def new_file_counter():
    line_counter = 0
    for line in open(new_endpoint_file):
        line_counter = line_counter + 1
        if Linux_port_configuration in line:
                global new_file_line_number
                new_file_line_number = line_counter + 2
                return new_file_line_number
                break

def compare_old_and_new_file():
    print ("string exist status is " + str(String_exist))
    compare_counter = 0
    new_number_of_rows_to_keyword = new_file_counter()
    print(new_number_of_rows_to_keyword)
    if String_exist == False:
        print("Keyword does not exist and completely different applying the changes ")
        print("old endpoint and new one are not same , Updating the endpoints ")
        print("running command os.system('kubectl apply -f ' + new_endpoint_file)")
        os.system('kubectl apply -f ' + new_endpoint_file)
    elif String_exist == True:
        compare_counter = 0
        for line in open(old_endpoint_file):
            compare_counter = compare_counter + 1
            if compare_counter >= old_number_of_rows_to_keyword:
                old_compare_file.write(line)
        compare_counter = 0
        for line in open(new_endpoint_file):
            compare_counter = compare_counter + 1
            if compare_counter >= new_number_of_rows_to_keyword:
                print(line)
                new_compare_file.write(line)
        new_compare_file.close()
        old_compare_file.close()
        status = filecmp.cmp(compare_new, compare_old)
        print(status)
        if status == False :
            print("Updating the Endpoints ")
            print("Compare is finished, The file need to be updated, runing the update")
            print("Running the command: os.system('kubectl apply -f ' + new_endpoint_file)")
            os.system('kubectl apply -f ' + new_endpoint_file)




print("Version 0.0.5")
check_the_file_status()
copy_the_source_table()
new_file.close()
compare_old_and_new_file()
