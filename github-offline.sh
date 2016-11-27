#!/bin/bash
IFS="
"

# 基础变量
app=GitHub.application
host=github-windows.s3.amazonaws.com/
url_path=http://$host
app_path=''
res_path=''
manifest_path=''
wwget='wget --continue --directory-prefix=./ --force-directories --timestamping '

# 下载 GitHub.application
`eval $wwget$url_path$app`

# 解析 GitHub.application
while read -r line
do
        if [[ $line =~ "codebase" ]];
        then
                line=`echo ${line#*codebase=\"}`
                manifest_path=`echo ${line%%\"*}`
                # 替换路径中的\为/
                manifest_path=${manifest_path//\\//}
                # 替换路径中的' '为%20
                manifest_path=${manifest_path//\ /%20}
                res_path=`echo ${manifest_path%/*}`
        fi
done < ./$host$app

# 下载 GitHub.exe.manifest
`eval $wwget$url_path$manifest_path`

# 解析 GitHub.exe.manifest
# rm -rf manifest.sh
# echo '@echo off' >> manifest.sh
# echo '# rem Wget executable must be either a) in PATH, or b) in the same directory as this batch file.' >> manifest.sh
while read -r line
do 
	if [[ $line =~ "codebase" ]] || [[ $line =~ "<file" ]];
	then
		line=`echo ${line#*codebase=\"}`
		line=`echo ${line#*file\ name=\"}`
		line=`echo ${line%%\"*}`
		# 替换路径中的\为/
		line=${line//\\//}
		shell=$wwget$url_path$res_path'/'$line'.deploy'
		# 下载 GitHub.exe.manifest 中列出的文件
		`eval $shell`
		# echo $shell >> ./manifest.sh
	fi
done < """$host${manifest_path//%20/ }"""

# echo 'pause' >> manifest.sh
# chmod u+x manifest.sh

filename=`echo ${res_path#*/}`
#mv $host $filename
#tar -zcvf $filename'.tar.gz' $filename
tar -zcvf $filename'.tar.gz' $host
#rm -rf $filename'/'
