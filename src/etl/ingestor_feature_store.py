import sqlalchemy
import pandas as pd
import datetime

class Utils:
    @staticmethod
    def date_range(date_start:str, date_stop:str, period:str='daily', date_format:str='%Y-%m-%d') -> list:
        datetime_start = datetime.datetime.strptime(date_start, date_format)
        datetime_stop = datetime.datetime.strptime(date_stop, date_format)

        dates = []
        while datetime_start < datetime_stop:
            dates.append(datetime_start.strftime(date_format))
            datetime_start += datetime.timedelta(days=1)

        if period == 'daily':
            return dates
        elif period == 'monthly':
            return [i for i in dates if i.endswith('01')]
        else:
            return None

class Injestor:
    def __init__(self, database_path_sqlite:str, table:str, key_field:str = 'dtReference'):
        self.path = database_path_sqlite
        self.table = table
        self.key_field = key_field
        self.engine = self.create_db_engine()

    def create_db_engine(self) -> sqlalchemy.Engine:
        return sqlalchemy.create_engine(f"sqlite:///{self.path}")

    def import_query(self, sql_path:str) -> str:
        with open(sql_path) as file:
            return file.read()
        
    def table_exist(self) -> bool:
        with self.engine.connect() as conn:
            tables = sqlalchemy.inspect(conn).get_table_names()
            return self.table in tables
        
    def execute_etl(self, sql_query:str) -> pd.DataFrame:
        with self.engine.connect() as conn:
            df = pd.read_sql_query(sql_query, conn)
        return df

    def insert_table(self, df:pd.DataFrame) -> bool:
        with self.engine.connect() as conn:
            df.to_sql(self.table, conn, if_exists="append", index=False)
        return True
        
    def delete_table_rows(self, value:str) -> bool:
        query = f"DELETE FROM {self.table} WHERE {self.key_field} = {value};"
        with self.engine.connect() as conn:
            conn.execute(sqlalchemy.text(query))
            conn.commit()
        return True

    def update_table(self, raw_query:str, value:str) -> None:
        if self.table_exist():
            print('Deleting table...')
            self.delete_table_rows(value)

        df = self.execute_etl(raw_query.format(date=value))
        print('Inserting in table...')
        self.insert_table(df)
        print('Ok!')
    
if __name__ == '__main__':
    database = "/media/lps/Storage/codes/olist-ml-model/data/olist.db"
    table_name = "product"

    injestor = Injestor(database_path_sqlite=database, table=table_name)
    sales_query = injestor.import_query(sql_path=f'{table_name}.sql')
        
    injestor.update_table(sales_query, value='2017-01-01')

    print(Utils.date_range('2017-01-01', '2018-01-01', period='monthly'))