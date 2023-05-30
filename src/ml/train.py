import sqlalchemy
import pandas as pd
from sklearn import model_selection
from sklearn.tree import DecisionTreeClassifier
from sklearn import pipeline
from feature_engine import imputation

pd.set_option('display.max_rows', 1000000)

DB_PATH = "/media/lps/Storage/codes/olist-ml-model/data/olist.db"
TABLE_NAME = "abt_olist_churn"

def read_table(table_name:str) -> pd.DataFrame:
    engine = sqlalchemy.create_engine(f"sqlite:///{DB_PATH}")
    with engine.connect() as conn:
        return pd.read_sql_table(table_name, con=conn)


if __name__ == "__main__":
    df = read_table(table_name=TABLE_NAME)

    print(df["dtReference"].unique())

    # database out of time to avaluate the model
    # It doesn't worth to use when the database is small
    df_oot = df[df['dtReference'] == "2018-01-01"].copy()

    # train database
    df_train = df[df['dtReference'] != "2017-01-01"].copy()

    var_identity = ["dtReference", "idVendedor"]
    target = "flChurn"

    features = [col for col in df_train.columns.to_list() if col not in var_identity + [target]]

    X_train, X_test, y_train, y_test = model_selection.train_test_split(df_train[features], df_train[target], train_size=0.8, random_state=42)

    # the proportions need to be similar for each one
    print(f'Train proportion: {y_train.mean()}')
    print(f'Test proportion: {y_test.mean()}')

    # Explore
    # knowning which variables are missing values
    # print(df.isna().sum().sort_values(ascending=False))

    # Transform
    # missing variables that will be given the value -100
    missing_minus_100 = ['avgIntervaloVendas',
                     'maxNota',
                     'minNota',
                     'avgNota',
                     'avgVolumeProduto',
                     'minVolumeProduto',
                     'maxVolumeProduto',
                    ]
    
    # missing variables that will be given the value 0
    missing_0 = ['avgQtdeParcelas',
                'minQtdeParcelas',
                'maxQtdeParcelas',
                'pctPedidoAtraso'
                ]

    # replacing missing values by -100
    imputer_minus_100 = imputation.ArbitraryNumberImputer(arbitrary_number=-100, variables=missing_minus_100)
    # replacing missing values by 0
    imputer_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0, variables=missing_0)

    # model
    model = DecisionTreeClassifier()

    # pipeline
    # transforms and model together
    model_pipeline = pipeline.Pipeline([
        ('imputer minus 100', imputer_minus_100),
        ('imputer 0', imputer_0),
        ('model decision tree', model),
    ], verbose=True)

    # fit the model
    model_pipeline.fit(X=X_train, y=y_train)

    # predicting
    print(model_pipeline.predict(X=X_test))
    # print(model_pipeline.predict(X=df_oot[features]))