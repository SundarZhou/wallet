# Description
  Wallet Application  -- Interview Coding Test

## Start
```
bundle install
rails db:create && rails db:migrate
rails db:migrate
rails db:seed
rails s
```
## API

### REGISTER
`POST account`

### LOGGING IN
`POST /login**`

### User can deposit money into her wallet
`POST /deposit`

### User can withdraw money from her wallet
`POST /withdraw**`

### User can send money to another user
`POST /transfer`


### User can check her wallet balance
`GET /check`**`

### User can see her wallet transaction history
`GET /histories`


## Spec Test
```
rspec ./spec/model_spec.rb

rspec ./spec/api_spec.rb
```

## TODO
* 规范异常错误返回的code与错误信息
* 自定义报错类型便于汇总