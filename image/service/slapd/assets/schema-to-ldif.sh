#!/bin/bash

SCHEMAS=$1

tmpd=`mktemp -d`
pushd ${tmpd} >>/dev/null

echo "include /etc/ldap/schema/core.schema" >> convert.dat
echo "include /etc/ldap/schema/cosine.schema" >> convert.dat
echo "include /etc/ldap/schema/nis.schema" >> convert.dat
echo "include /etc/ldap/schema/inetorgperson.schema" >> convert.dat

for schema in ${SCHEMAS} ; do
    echo "include ${schema}" >> convert.dat
done

slaptest -f convert.dat -F .

if [ $? -ne 0 ] ; then
    echo "slaptest conversion failed"
    exit 
fi

for schema in ${SCHEMAS} ; do
    fullpath=${schema}
    schema_name=`basename ${fullpath} .schema`
    schema_dir=`dirname ${fullpath}`
    ldif_file=${schema_name}.ldif

    find . -name *${schema_name}.ldif -exec mv '{}' ./${ldif_file} \;

    # TODO: these sed invocations could all be combined
    sed -i --follow-symlinks "/dn:/ c dn: cn=${schema_name},cn=schema,cn=config" ${ldif_file}
    sed -i --follow-symlinks "/cn:/ c cn: ${schema_name}" ${ldif_file}
    sed -i --follow-symlinks '/structuralObjectClass/ d' ${ldif_file}
    sed -i --follow-symlinks '/entryUUID/ d' ${ldif_file}
    sed -i --follow-symlinks '/creatorsName/ d' ${ldif_file}
    sed -i --follow-symlinks '/createTimestamp/ d' ${ldif_file}
    sed -i --follow-symlinks '/entryCSN/ d' ${ldif_file}
    sed -i --follow-symlinks '/modifiersName/ d' ${ldif_file}
    sed -i --follow-symlinks '/modifyTimestamp/ d' ${ldif_file}
    
    # slapd seems to be very sensitive to how a file ends. There should be no blank lines.
    sed -i --follow-symlinks '/^ *$/d' ${ldif_file}

    mv ${ldif_file} ${schema_dir}
done

popd >>/dev/null
rm -rf $tmpd