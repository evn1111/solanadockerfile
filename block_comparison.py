import requests
import json
import os
import sys
import time

def get_etherscan_block(api_key: str) -> int:
    url = f"https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey={api_key}"
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()
        return int(data['result'], 16)  # Конвертация hex в int
    except Exception as e:
        print(f"Ошибка Etherscan: {e}")
        sys.exit(1)

def get_blockcypher_block() -> int:
    url = "https://api.blockcypher.com/v1/eth/main"
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()
        return data['height']
    except Exception as e:
        print(f"Ошибка BlockCypher: {e}")
        sys.exit(1)

def main():
    # Получение API-ключа из переменных окружения
    api_key = os.getenv('ETHERSCAN_API_KEY')
    if not api_key:
        print("ERROR: Установите переменную окружения ETHERSCAN_API_KEY")
        sys.exit(1)

    # Получение значений блоков
    etherscan_block = get_etherscan_block(api_key)
    blockcypher_block = get_blockcypher_block()
    
    print(f"Etherscan (hex->dec): {etherscan_block}")
    print(f"BlockCypher:          {blockcypher_block}")
    print(f"Разница:              {abs(etherscan_block - blockcypher_block)} блоков")
    
    # Проверка рассинхронизации (допустимо до 3 блоков)
    if abs(etherscan_block - blockcypher_block) > 3:
        print("WARNING: Сервисы рассинхронизированы!")
        sys.exit(1)
    else:
        print("OK: Данные в допустимом диапазоне")
        sys.exit(0)

if __name__ == "__main__":
    main()