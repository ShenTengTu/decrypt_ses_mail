# 解密由AWS SES接收的Email原始碼檔案
使用 __AWS SDK for Ruby__ 來解密存儲在AWS S3中由AWS SES接收到的電子郵件文件。

使用AWS SES（Amazon Simple Email Service）接收電子郵件時需要設定『郵件接收規則集』。在規則中可以建立“S3 Action”讓接收的電子郵件原始碼儲存到指定的S3 Bucket中。

S3 Action的設定項目為：
- S3 bucket：用於保存收到的電子郵件的S3 Bucket的名稱。
- Object key prefix ：S3 Bucket的物件鍵前綴。（資料夾名稱）
- Encrypt Message：希望SES加密電子郵件。
    - KMS key：SES應該用於加密電子郵件的客戶主金鑰。
- SNS topic：執行Action時Amazon SNS將進行通知的主題

被SES加密的電子郵件原始碼檔案必須使用您必須使用Amazon S3加密客戶端來進行解密。

以下的AWS SDK有包含 Amazon S3 加密用戶端：
- AWS SDK for Java – `AmazonS3EncryptionClient `
- __AWS SDK for Ruby__ – `Aws::S3::Encryption::Client `
- AWS SDK for .NET –  `AmazonS3EncryptionClient`
- AWS SDK for Go –  `s3crypto`

## 環境變數設置
我們使用 __dotenv__ 來進行必要環境變數的配置，詳見 __.env.template__ 文件。

```
export AWS_ACCESS_KEY_ID=YOURS_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOURS_AWS_SECRET_ACCESS_KEY
export AWS_REGION=YOURS_AWS_REGION
S3_BUCKET=YOURS_S3_BUCKET
S3_KEY_PREFIX=YOURS_S3_KEY_PREFIX
KMS_KEY_ID=YOURS_KMS_KEY_ID
```

## 執行
下載原始碼：
```
git clone https://github.com/ShenTengTu/decrypt_ses_mail.git
```

安裝依賴程式庫：
```
cd decrypt_ses_mail
bundle install
```

執行程式：
```
ruby main.rb
```

程式會從你指定的S3 Bucket中尋找擁有特定鍵前綴（如`info/`）的S3物件(該物件為被SES加密的電子郵件原始碼檔案)，下載並經由指定的金鑰來解密檔案，並儲存到當前工作目錄下與鍵前綴同名的資料夾(如`info`）中。

## 參考
- [Creating receipt rules : S3 action](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-action-s3.html)
- [API : AWS SDK for Ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/EncryptionV2.html)



