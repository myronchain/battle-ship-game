# cs251_proj3

## 环境配置

1. 使用ganache-cli模拟以太坊
- 安装ganache
    ```shell script
    npm install -g ganache-cli  
    ```
- 启动ganache
    ```shell script
    export NODE_OPTIONS=--openssl-legacy-provider
    nohup ganache-cli --host 0.0.0.0 > log.log 2>&1 &
    ```

## 链码调试数据

玩家1 2均将舰艇放在第一行前两个格子内

store_board_commitment:
玩家1：0x7bd85425e9fea175aba2662db3ab5afc30b66ba5d870447f3a594c8ebea36071
玩家2：0x8904b6401a8b074f06eb282a9f6296e305c4d38ed535ef1be1de05a3b494163b

check_one_ship:
玩家1 
命中1：
- 0x7472756533343833383835383638
- ["0xe4f630683e3db7c6d74e0932997398e3ff2ee730441afdbd774777da41018844", "0xf1f972a784edc9f208dce7944be9969ca0bc6953a2d57a5b623b7730fe95e075", "0x05069a3a77ec20880f77473deec20af17aa588879075f434cab06fc4098cf3f4", "0x6b0a52acf9a1ad0d64f6091af2f2f3f7239dcbf7d1c89cd97dfdea39e90fdbfa"]
- 0
- 玩家2账户
命中2：
- 0x7472756531393839383832353036
- ["0xd43801733c9daa13ccb469093ac9f4e5823054f7843c0ac2d97dd559561e8397", "0xf1f972a784edc9f208dce7944be9969ca0bc6953a2d57a5b623b7730fe95e075", "0x05069a3a77ec20880f77473deec20af17aa588879075f434cab06fc4098cf3f4", "0x6b0a52acf9a1ad0d64f6091af2f2f3f7239dcbf7d1c89cd97dfdea39e90fdbfa"]
- 1
- 玩家2账户

玩家1
claim_win


参考：https://zhuanlan.zhihu.com/p/370200986