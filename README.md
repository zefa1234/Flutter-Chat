##  介紹影片

https://www.youtube.com/watch?v=_-THqNxvSoY&ab_channel=%E5%BC%B5%E5%93%B2%E4%BF%AE

##  Google登入相關事項

1. 在firebase console中 Authentication>Sign-in method 新增供應商 Google

2. 獲取SHA1指紋
    * 方法1. 使用cmd輸入: 

      ```terminal
      {keytool.exe_path} -list -v -keystore {debug.keystore_path} -alias androiddebugkey -storepass android -keypass android
      ```

      須將{ }內替換成對應路徑：
      
      keytool.exe 預設存在 `java\jre\bin` 

      debug.keystore預設存在 `C:\user\.android`

      例：    
      ```terminal
      G:\Android\jre\bin\keytool.exe -list -v -keystore C:\Users\username\.
      android\debug.keystore -alias androiddebugkey -storepass android 
      -keypass android
      ```

   * 方法2.在`Chatter-App\android`使用cmd輸入： 
       
         gradlew signingReport

3. 將獲取的SHA1到firebase console中的專案設定新增指紋

4. 將最新的google-services下載並放到`chat app\Chatter-App\android\app`
