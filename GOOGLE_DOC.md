https://issues.apache.org/jira/projects/ARTEMIS/issues/ARTEMIS-4306?filter=allopenissues


Description
It would be useful to have metrics for authn/z successes and failures as well as for metrics related to the corresponding caches.
See this discussion on the users mailing list for more details: https://lists.apache.org/thread/g6ygyo4kb3xhygq8hpw7vsl3l2g5qt92


Mike Artz added a comment - 01/Aug/23 22:12
Do you think this could be implemented by implementing a ActiveMQSecurityManager?
EditDelete

Justin Bertram added a comment - 01/Aug/23 23:38 - edited
Mike Artz, off the cuff I wouldn't expect this to be possible. In order to register a metric you need to use org.apache.activemq.artemis.core.server.metrics.MetricsManager which is not passed to security manager implementation. In any case, you'd want to implement this in org.apache.activemq.artemis.core.security.impl.SecurityStoreImpl next to the authn/z caches so that the metrics would work regardless of the security manager implementation.

Mike Artz added a comment - 03/Aug/23 03:21 - edited
Just wondering which metrics we are talking about - these are what I have so far. 
EDIT: Took out the response time metrics and took out the ratio
Authentication Metrics:
authn_success_count: Number of successful authentication attempts.
authn_failure_count: Number of failed authentication attempts.
 
Authorization Metrics: 
authz_success_count: Number of successful authorization checks. 
authz_failure_count: Number of failed authorization checks. 
 
Cache Metrics: 
authn_cache_size: Size of the authentication cache.
authn_cache_hit_count: Number of cache hits for authentication.
authn_cache_miss_count: Number of cache misses for authentication.
authz_cache_size: Size of the authorization cache.
authz_cache_hit_count: Number of cache hits for authorization. 
authz_cache_miss_count: Number of cache misses for authorization. 
 
?Extra
auth_cache_invalidated_count: Number of times the authn cache was invalidated.
authz_cache_invalidated_count: Number of times the authz cache was invalidated.
EditDelete

Justin Bertram added a comment - 03/Aug/23 17:52 - edited
I linked the original discussion in the description. I think success & failure counts for both authn & authz are a good place to start. The user in the email thread requested individual success & failure counts for a handful of individual permission types, but I'm not convinced of the utility of those. In my opinion it doesn't make sense to provide metrics for only some of the permission types and there are 10 permission types so that would be 20 metrics for authz rather than just 2. At this point I just don't see the justification for the additional complexity that would add.
We can get metrics for both authn & authz caches mostly for free by using Micrometer's cache integration similar to what's already been done with various system metrics (recent work via ARTEMIS-4292).
Lastly, there needs to be a flag to enable/disable these metrics like there is for the JVM, Netty, etc.


https://github.com/micrometer-metrics/micrometer/tree/main/micrometer-core/src/main/java/io/micrometer/core/instrument/binder/cache

/Users/mikeartz/dev/activemq-artemis/tests/artemis-test-support/src/main/java/org/apache/activemq/transport/amqp/client/sasl/SaslAuthenticator.java


/Users/mikeartz/dev/activemq-artemis/tests/artemis-test-support/src/main/java/org/apache/activemq/transport/amqp/client/sasl/AbstractMechanism.java



https://issues.apache.org/jira/browse/ARTEMIS-4292



run test testFileDescriptorsMetricsPositive

look at server -> metricsManager -> meterRegistry -> meterMap -> 
	MeterId 1
		key=MeterID
name=jvm.buffer.count 
value=DefaultGauge 
	ref=WeakReference 
		referent=ManagementFactoryHelper
			objname=ObjName
_CanonicalName=”java.nio.name=direct,type=BufferPool 

	MeterId 20 something
		key=MeterID
name=process.files.max 
value=DefaultGauge 
	ref=WeakReference 
		referent=OperatingSystemImpl
			jvm=VMManagementImpl
				vmArgs=Collections$UnmodfiableRandomAccesList
0 = "-agentlib:jdwp=transport=dt_socket,address=127.0.0.1:52171,suspend=y,server=n"
1 = "-ea"
2 = "-Djgroups.bind_addr=::1"
3 = "-Dorg.apache.activemq.artemis.utils.RetryRule.retry=false"
4 = "-Dbrokerconfig.maxDiskUsage=100"
5 = "-Dorg.apache.activemq.artemis.core.remoting.impl.netty.TransportConstants.DEFAULT_QUIET_PERIOD=0"
6 = "-Dorg.apache.activemq.artemis.core.remoting.impl.netty.TransportConstants.DEFAULT_SHUTDOWN_TIMEOUT=0"
7 = "-Djava.library.path=/Users/mikeartz/dev/activemq-artemis/tests/integration-tests/../../target/bin/lib/linux-x86_64:/Users/mikeartz/dev/activemq-artemis/tests/integration-tests/../../target/bin/lib/linux-i686"
8 = "-Djgroups.bind_addr=localhost"
9 = "-Djava.net.preferIPv4Stack=true"
10 = "-Dbasedir=/Users/mikeartz/dev/activemq-artemis/tests/integration-tests"
11 = "-Djdk.attach.allowAttachSelf=true"
12 = "-Dlog4j2.configurationFile=file:/Users/mikeartz/dev/activemq-artemis/tests/integration-tests/../../tests/config/log4j2-tests-config.properties"
13 = "-Dorg.apache.activemq.SERIALIZABLE_PACKAGES=java.lang,javax.security,java.util,org.apache.activemq,org.fusesource.hawtbuf"
14 = "-Didea.test.cyclic.buffer.size=1048576"
15 = "-javaagent:/Users/mikeartz/Library/Caches/JetBrains/IntelliJIdea2023.1/groovyHotSwap/gragent.jar"
16 = "-javaagent:/Users/mikeartz/Library/Caches/JetBrains/IntelliJIdea2023.1/captureAgent/debugger-agent.jar=file:/private/var/folders/gq/fhhlt6wd7hl_f6_7ptc6zns00000gn/T/capture1.props"
17 = "-Dfile.encoding=UTF-8"
			value=FileDescriptorMetrics$lambda
				arg=FileDescriptorMetrics
					osBean=OopeartingSystemImpl
					tags=Collections$EmptyList
					osBeanClass=interface com.sun.management.UnixOperatingSystemMXBean
openFilesMethod=public abstract long com.sun.management.UnixOperatingSystemMXBean.getOpenFileDescriptorCount()
maxFilesMEthod=public abstract long com.sun.management.UnixOperatingSystemMXBean.getMaxFileDescriptorCount()


server -> configuration -> jmxManagementEnabled = true
server -> configuration -> jmxDomain = “org.apache.activemq.artemis”
server -> configuration -> jmxUseBrokerName = true
server -> configuration -> metricsConfiguration -> plugin -> meterRegistry -> meterMap



For examples -> 
/Users/mikeartz/dev/activemq-artemis/artemis-server/src/main/java/org/apache/activemq/artemis/core/server/impl/QueueImpl.java

which has a reference for 

/Users/mikeartz/dev/activemq-artemis/artemis-server/src/main/java/org/apache/activemq/artemis/core/server/impl/QueueMessageMetrics.java


There are over 2400 metrics in meterMap when I run on “regular” local instance and not the test but there  can be many metrics of the same name for example 

These are two different metrics 
{Meter$Id@11065} "MeterId{name='netty.pooled.arena.active.allocations.num', tags=[tag(broker=0.0.0.0),tag(pool_arena_index=4),tag(pool_arena_type=heap),tag(size=huge)]}" -> {DefaultGauge@11066} 

{Meter$Id@11063} "MeterId{name='netty.pooled.arena.active.allocations.num', tags=[tag(broker=0.0.0.0),tag(pool_arena_index=4),tag(pool_arena_type=direct),tag(size=small)]}" -> {DefaultGauge@11064} 


ACTIVEMQ.CLUSTER.ADMIN.USER
CHANGE ME!!


https://activemq.apache.org/components/artemis/migration-documentation/authentication.html

https://activemq.apache.org/components/artemis/documentation/latest/masking-passwords


https://activemq.apache.org/components/artemis/documentation/latest/management

service:jmx:rmi:///jndi/rmi://localhost:1099/jmxrmi

https://lists.apache.org/thread/g6ygyo4kb3xhygq8hpw7vsl3l2g5qt92

/Users/mikeartz/dev/activemq-artemis/artemis-core-client/src/main/java/org/apache/activemq/artemis/api/config/ActiveMQDefaultConfiguration.java

Commands to run 
mvn install -DskipTests
mvn clean verify

Tests with authenticationMetrics or authorizationMetrics 
OutgoingConnectionTest
testMultipleSessionsThrowsException
line 189
authenticationMetrics.incrementAuthenticationCacheCount(false);



testMultipleSessionsThrowsException
line 385
authenticationMetrics.incrementAuthenticationCount(false);


testSimpleMessageSendAndReceiveXA
line 385
authenticationMetrics.incrementAuthenticationCacheCount(false);




testConnectionCredentials
line 189
authenticationMetrics.incrementAuthenticationCacheCount(false);


line 205
authenticationMetrics.incrementAuthenticationCachePutCount();



testJMSContext
line 189
authenticationMetrics.incrementAuthenticationCacheCount(false);


testSharedActiveMQConnectionFactoryWithClose
line 189
authenticationMetrics.incrementAuthenticationCacheCount(false);




testConnectionCredentialsOKRecovery
line 189
authenticationMetrics.incrementAuthenticationCacheCount(false);


line 205
authenticationMetrics.incrementAuthenticationCacheCount(false);


line 471
line 472 
authorizationMetrics.incrementAuthorizationCacheCount(granted);
authorizationMetrics.incrementAuthorizationCount(granted);


line 430
authenticationMetrics.incrementAuthenticationCacheCount(false);


OutgoingConnectionNoJTATest
testSimpleMessageSendAndReceiveNotTransacted
authenticationMetrics.incrementAuthenticationCacheCount(false);
line 471
line 472 
authorizationMetrics.incrementAuthorizationCacheCount(granted);
authorizationMetrics.incrementAuthorizationCount(granted);


testSimpleMessageSendAndReceiveSessionTransacted2
authenticationMetrics.incrementAuthenticationCacheCount(false);
line 430 
authenticationMetrics.incrementAuthenticationCacheCount(false);


testSimpleSendNoXAJMSContext

ActiveMQMessageHandlerSecurityTest
	testSimpleMEssageREceivedOnQueueWithSecuritySucceeds
authorizationMetrics.incrementAuthorizationCacheCount(granted);
authorizationMetrics.incrementAuthorizationCount(granted);



TemporaryDestinationTest.testForSecurityCacheLeak


JMSSecurityTest.testCreateQueueConnection
JMSSecurityTest.testMaskedPasswordURLUsernamePassword
JMSSecurityTest.testMaskedPasswordOnJMSContext
JMSSecurityTest… all 

SimpleJNDIClientTest.testVMCF0
SimpleJNDIClientTest.testRemoteCFWithTCPUSerPassword

DualAuthenticationTest.testDualAuthentication

STOPPED RIGHT AT org.apache.activemq.artemis.tests.integration.ssl.CoreClientOverTwoWaySSLTest




Picked up at SecurityTest 
testNoCacheConnectExceptionRegex
testDeleteTempQueueWithoutRole
testCustomSecurityManager
testJAASSecurityManagerAuthenticationBadPassword
testSendMessageUpdateRoleCached
testJAASSecurityManagerAuthorizationPositiveGuest
testCreateDurableQueueWithoutRole
testReauthenticationIsCached
testJAASSecurityManagerAuthentication
testJAASSecurityManagerAuthorizationSameAddressDifferentQueuesDotSyntax
testJAASSecurityManagerAuthenticationWithRegexpsWantClientAuth
testNoCacheException
testCreateSessionWithCorrectUserWrongPass
testJAASSecurityManagerAuthorizationNegativeWithCerts
testJAASSecurityManagerAuthorizationPositiveWithCertsWantClientAuth
testNonBlockSendManagementWithoutRole
testSendWithoutRole
…testSendMessageUpdateSender
testSendMessageUpdateRoleCached2





artemis-server/src/main/java/org/apache/activemq/artemis/core/security/SecurityMetrics.java
