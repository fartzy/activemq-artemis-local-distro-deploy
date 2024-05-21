RELEASE=2.31.0-SNAPSHOT


ARTEMIS_HOME="/Users/mikeartz/dev/activemq-artemis/artemis-distribution/target/apache-artemis-"${RELEASE}"-bin/apache-artemis-"${RELEASE}
${ARTEMIS_HOME}/bin/artemis create mybroker

cp broker.xml mybroker/etc/
cp management.xml mybroker/etc/
cp bootstrap.xml mybroker/etc/
cp log4j2.properties mybroker/etc/
cp artemis.profile mybroker/etc/
cp artemis mybroker/bin/
cp login.config mybroker/etc/
cp artemis-roles.properties mybroker/etc/
cp artemis-users.properties mybroker/etc/

