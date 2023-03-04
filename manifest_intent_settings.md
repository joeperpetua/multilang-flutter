=============
Chrome: OK
Brave: OK
Wikipedia: NO
Instagram: OK
Whatsapp: NO
Gmail: OK
Anki: OK


<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
</intent-filter>

=============

=============
Chrome: NO
Brave: NO
Wikipedia: OK
Instagram: OK
Whatsapp: OK
Gmail: OK
Anki: OK


<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="http" />
    <data android:scheme="https" />
</intent-filter>

=============

=============
Chrome: OK
Brave: OK
Wikipedia: OK
Instagram: OK
Whatsapp: OK
Gmail: OK
Anki: OK


<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" />
</intent-filter>

=============

