

<h1 align="center" style="margin-bottom: 0;">
    Balance AI - Risk Model
   
</h1>


Trading is psychologically demanding due to the need for rapid decision-making amidst a vast amount of data. Traders face constant pressure to interpret market information, assess risk, and execute trades swiftly. 

Managing vast datasets can lead to information overload and may contribute to decision-making errors. The importance of effective data management and analysis tools in the modern trading process is thus beyond question.

When confronted with the task of handling extensive datasets, machine learning is the foremost solution that comes to mind. However, in certain scenarios, expert systems have the potential to outperform machine learning approaches. 

**Balance AI Risk** - Comprehensive toolkit tailored to handle various aspects of risk assessment, decision-making, and strategy optimization. 

Built as a Python module enriched by CLIPS expert systems programming language, it can empower traders and financial professionals to design robust risk management strategies, optimize their trading performance, and navigate the complexities of financial markets with greater confidence and efficiency.

> These are just a few use case that can be built using Balance AI Risk:
> - build **risk management** models
> - validate **trading strategies**
> - **simulate** risks 
> - execute a variety of **risk** strategies 


## Balance AI Risk components

The project consists of three components:

- Python framework to execute expert systems models.
- CLIPS example model(s)
- Docker containter allowing to run models as an API endpoints


## Requirements

This repository contains Balance AI Risk framework and example CLIPS model for crypto trading. You can clone it and experiment with your own models. You need the following requirements installed in your system:

- [Python](https://www.python.org/) (recommended `3.8+`)
- [Docker Engine](https://docs.docker.com/engine/install/)
- [Pip](https://pip.pypa.io/en/stable/installation/)
- Flask==2.1.0
- Werkzeug==2.2.2
- Flask-Cors==3.0.9
- Flask-JWT-Simple==0.0.3
- urllib3==1.25.10
- virtualenv==20.0.31
- virtualenvwrapper==4.8.4
- gunicorn==20.0.4
- pandas==1.1.2
- clipspy==0.3.3


## Set up your environment

Follow these instructions to have your local environment prepared.

1. Install required dependencies:

    ```bash
    pip install --upgrade pip
    pip install -r requirements.txt
    ```

### Run as standalone


```bash
   python app.py
```

### Run as Docker container

1. Build docker:
   ```bash
   docker build . --platform linux/amd64 -t balance_ai_risk
   ```

2. Run docker container:
    ```bash
    docker run -p 8081:8081 balance_ai_risk
    ```



## Interact with the model

The model is available as REST service (GET/POST) at [http://localhost:8081/risks](http://localhost:8081/risks).

Example payload:

```
   {
    "ot_user_id": "1",
    "ot_risk_input": {
      "ot_user_balance": 150,
      "ot_user_timeframe": "DAY",
      "position-data": [
        {
          "ot_pos_dealid": "BTC",
          "ot_pos_cc": "USD",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "BTC/USD",
          "ot_instr_id": "BTC/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 34157.06,
          "ot_pos_contractsize": "22222222",
          "ot_risk_check": "true",
          "ot_pos_controlled": "true",
          "ot_pos_stop": 37318.11
        },
        {
          "ot_pos_dealid": "ADD",
          "ot_pos_cc": "ADD",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "ADD",
          "ot_instr_id": "ADD/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 0,
          "ot_pos_contractsize": 11.093895,
          "ot_instr_bid": 0,
          "ot_risk_check": "false",
          "ot_instr_offer": 0,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "SXP",
          "ot_pos_cc": "SXP",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "SXP",
          "ot_instr_id": "SXP/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 1.014,
          "ot_pos_contractsize": 0.00330854,
          "ot_instr_bid": 0.3105,
          "ot_risk_check": "false",
          "ot_instr_offer": 0.3105,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "UNI",
          "ot_pos_cc": "UNI",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "UNI",
          "ot_instr_id": "UNI/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 4.225,
          "ot_pos_contractsize": 124,
          "ot_instr_bid": 6.139,
          "ot_risk_check": "false",
          "ot_instr_offer": 6.139,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "SNT",
          "ot_pos_cc": "SNT",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "SNT",
          "ot_instr_id": "SNT/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 0.1583,
          "ot_pos_contractsize": 579,
          "ot_instr_bid": 0.03878,
          "ot_risk_check": "false",
          "ot_instr_offer": 0.03878,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "LINK",
          "ot_pos_cc": "LINK",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "LINK",
          "ot_instr_id": "LINK/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 15.821879316304969,
          "ot_pos_contractsize": 9.99,
          "ot_instr_bid": 17.87,
          "ot_risk_check": "false",
          "ot_instr_offer": 17.87,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "EON",
          "ot_pos_cc": "EON",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "EON",
          "ot_instr_id": "EON/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 0,
          "ot_pos_contractsize": 22.18779,
          "ot_instr_bid": 0,
          "ot_risk_check": "false",
          "ot_instr_offer": 0,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "EOP",
          "ot_pos_cc": "EOP",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "EOP",
          "ot_instr_id": "EOP/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 0,
          "ot_pos_contractsize": 22.18779,
          "ot_instr_bid": 0,
          "ot_risk_check": "false",
          "ot_instr_offer": 0,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "MEETONE",
          "ot_pos_cc": "MEETONE",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "MEETONE",
          "ot_instr_id": "MEETONE/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 0.005732,
          "ot_pos_contractsize": 11.093895,
          "ot_instr_bid": 0,
          "ot_risk_check": "false",
          "ot_instr_offer": 0,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "SALT",
          "ot_pos_cc": "SALT",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "SALT",
          "ot_instr_id": "SALT/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 3.205,
          "ot_pos_contractsize": 3.51834,
          "ot_instr_bid": 0.029,
          "ot_risk_check": "false",
          "ot_instr_offer": 0.029,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "BNB",
          "ot_pos_cc": "BNB",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "BNB",
          "ot_instr_id": "BNB/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 23.64,
          "ot_pos_contractsize": 0.1497921,
          "ot_instr_bid": 301.38,
          "ot_risk_check": "false",
          "ot_instr_offer": 301.38,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        },
        {
          "ot_pos_dealid": "JEX",
          "ot_pos_cc": "JEX",
          "ot_pos_exchange": 1,
          "ot_pos_margin": 100,
          "ot_pos_size": 1,
          "ot_instr_name": "JEX",
          "ot_instr_id": "JEX/USD",
          "ot_instr_type": "CRYPTO",
          "ot_pos_direction": "BUY",
          "ot_pos_opening": 0.0002191425816948,
          "ot_pos_contractsize": 37.69125781,
          "ot_instr_bid": 0,
          "ot_risk_check": "false",
          "ot_instr_offer": 0,
          "ot_pos_controlled": false,
          "ot_pos_stop": null,
          "ot_pos_limit": null
        }
      ]
    }
  }
```
The ***position-data*** element defines all positions within the portfolio including the poistion that is being checked for risks. 

- "ot_pos_direction": "BUY" -> BUY/SELL transaction type
- "ot_pos_opening": 34157.06 -> price of the position open
- "ot_pos_contractsize": "1" -> amount of instrument to be transact
- "ot_risk_check": "true", -> true - riks to be checked on that position 
- "ot_pos_controlled": "true", -> true - position is being controlled (e.g. opened) , false - position in porfolio already 

#### The payload can be updated with any additional elements providing the corresponding CLP (Expert System) model is being updated with those elements. 

### Experiment with your own model

1. Add your CLP model to the ai_models directory. 

2. Modify the ***config_balance.json*** file to include your own model.

```
{
  "ot_model": "your_own_model"
}
```
3. Restart Balance AI Risk

### More information

More information can be found in our medium post at: [AI Expert System to Boost Trading](https://balancedao.medium.com/ai-expert-system-to-boost-trading-bd0f871f603e)

### Disclaimer

Any analysis, information or explanation we give to you about operations and performance on your trading account is not intended to be and should not be considered as advice. We do not provide investment, financial, legal or tax advice, especially we do not provide advice to conclude any transactions. This tool shall only analyse your trades, explain how it works, what is the trend, what is the possible risk etc. If you decide to use the information provided at the service, you do so at your own discretion and risk. The decision to conclude any transaction, including buying, selling, trading in securities or any other investments rest solely on you. Any trading or investment transactions involve a risk of substantial loses and shall be made based on the personalised investment advice of qualified financial professionals. We are not liable for any loss or damage that you, or any other person or entity incurs, as a result of any trading or investment transactions based on any information provided at the service.


