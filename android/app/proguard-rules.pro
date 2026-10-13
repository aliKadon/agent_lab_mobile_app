# pusher_client pulls in SLF4J, which looks for an optional logging backend at runtime.
# The backend isn't bundled, so tell R8 not to fail on the missing class.
-dontwarn org.slf4j.impl.StaticLoggerBinder
