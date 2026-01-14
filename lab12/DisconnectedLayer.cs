
using System.Data;
using Microsoft.Data.SqlClient;

namespace lab12;

public static class DisconnectedLayer
{
    private static DataTable? _playerTable;
    private static SqlDataAdapter? _adapter;

    public static void Benchmark(string connectionString)
    {
        try
        {
            Load(connectionString);

            var tempRow = AddPlayerToDataSet(
                nickName: "trinity",
                firstName: "Trinity",
                middleName: "",
                lastName: "Unknown",
                birthDate: new DateTime(1991, 2, 2),
                country: "USA",
                rating: 2400);

            PrintDataSet();

            tempRow["Rating"] = 2450;

            SaveChanges();

            Console.WriteLine($"[Disconnected] After SaveChanges PlayerID={tempRow["PlayerID"]}");

            tempRow.Delete();

            SaveChanges();

            Reload(connectionString);
            PrintDataSet();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    private static void Load(string connectionString)
    {
        try
        {
            if (_playerTable != null && _adapter != null)
                return;

            _playerTable = new DataTable("Player");
            
            var connection = new SqlConnection(connectionString);

            _adapter = new SqlDataAdapter(
                "SELECT PlayerID, NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating FROM Player;",
                connectionString);

            _adapter.InsertCommand = BuildInsertCommand(connection);
            _adapter.UpdateCommand = BuildUpdateCommand(connection);
            _adapter.DeleteCommand = BuildDeleteCommand(connection);

            _adapter.Fill(_playerTable);
            
            _playerTable.PrimaryKey = new[] { _playerTable.Columns["PlayerID"]! };
            
            var idCol = _playerTable.Columns["PlayerID"]!;
            idCol.AutoIncrement = true;
            idCol.AutoIncrementSeed = -1;
            idCol.AutoIncrementStep = -1;

            Console.WriteLine("[Disconnected] DataSet loaded.");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    private static void Reload(string connectionString)
    {
        try
        {
            if (_playerTable == null || _adapter == null)
            {
                Load(connectionString);
                return;
            }

            _playerTable.Clear();
            _adapter.SelectCommand!.Connection = new SqlConnection(connectionString);
            _adapter.Fill(_playerTable);

            Console.WriteLine("[Disconnected] DataSet reloaded.");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    private static DataRow AddPlayerToDataSet(
        string nickName,
        string firstName,
        string middleName,
        string lastName,
        DateTime birthDate,
        string country,
        int rating)
    {
        try
        {
            if (_playerTable == null)
                throw new InvalidOperationException("Call Load() before dataset operations.");

            var row = _playerTable.NewRow();
            row["NickName"] = nickName;
            row["FirstName"] = firstName;
            row["MiddleName"] = middleName;
            row["LastName"] = lastName;
            row["BirthDate"] = birthDate;
            row["Country"] = country;
            row["Rating"] = rating;

            _playerTable.Rows.Add(row);

            Console.WriteLine("[Disconnected] Row added to DataSet.");
            return row;
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
    }

    private static void PrintDataSet()
    {
        try
        {
            if (_playerTable == null)
            {
                Console.WriteLine("[Disconnected] DataSet is empty.");
                return;
            }

            Console.WriteLine("-- Data from DataSet Player --");
            Console.WriteLine(
                $"{"PlayerID",-10}{"NickName",-15}{"FirstName",-15}{"MiddleName",-15}{"LastName",-15}{"BirthDate",-15}{"Country",-15}{"Rating",-10}{"State",-12}");
            Console.WriteLine(new string('-', 120));

            foreach (DataRow row in _playerTable.Rows)
            {
                if (row.RowState == DataRowState.Deleted)
                    continue;

                Console.WriteLine(
                    $"{row["PlayerID"],-10}" +
                    $"{row["NickName"],-15}" +
                    $"{row["FirstName"],-15}" +
                    $"{row["MiddleName"],-15}" +
                    $"{row["LastName"],-15}" +
                    $"{row["BirthDate"],-15:yyyy-MM-dd}" +
                    $"{row["Country"],-15}" +
                    $"{row["Rating"],-10}" +
                    $"{row.RowState,-12}");
            }
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    private static void SaveChanges()
    {
        try
        {
            if (_playerTable == null || _adapter == null)
                throw new InvalidOperationException("Call Load() before SaveChanges().");
            var affected = _adapter.Update(_playerTable);
            Console.WriteLine($"[Disconnected] SaveChanges OK. Affected rows: {affected}");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    private static SqlCommand BuildInsertCommand(SqlConnection connection)
    {
        var cmd = new SqlCommand(
            """
            INSERT INTO Player (NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating)
            OUTPUT INSERTED.PlayerID
            VALUES (@NickName, @FirstName, @MiddleName, @LastName, @BirthDate, @Country, @Rating);
            """,
            connection);

        cmd.UpdatedRowSource = UpdateRowSource.FirstReturnedRecord;

        cmd.Parameters.Add("@NickName", SqlDbType.NVarChar, 50, "NickName");
        cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50, "FirstName");
        cmd.Parameters.Add("@MiddleName", SqlDbType.NVarChar, 50, "MiddleName");
        cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50, "LastName");
        cmd.Parameters.Add("@BirthDate", SqlDbType.Date, 0, "BirthDate");
        cmd.Parameters.Add("@Country", SqlDbType.NVarChar, 50, "Country");
        cmd.Parameters.Add("@Rating", SqlDbType.Int, 0, "Rating");

        return cmd;
    }

    private static SqlCommand BuildUpdateCommand(SqlConnection connection)
    {
        var cmd = new SqlCommand(
            """
            UPDATE Player
            SET NickName = @NickName,
                FirstName = @FirstName,
                MiddleName = @MiddleName,
                LastName = @LastName,
                BirthDate = @BirthDate,
                Country = @Country,
                Rating = @Rating
            WHERE PlayerID = @PlayerID;
            """,
            connection);

        cmd.Parameters.Add("@NickName", SqlDbType.NVarChar, 50, "NickName");
        cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50, "FirstName");
        cmd.Parameters.Add("@MiddleName", SqlDbType.NVarChar, 50, "MiddleName");
        cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50, "LastName");
        cmd.Parameters.Add("@BirthDate", SqlDbType.Date, 0, "BirthDate");
        cmd.Parameters.Add("@Country", SqlDbType.NVarChar, 50, "Country");
        cmd.Parameters.Add("@Rating", SqlDbType.Int, 0, "Rating");
        
        var id = cmd.Parameters.Add("@PlayerID", SqlDbType.Int, 0, "PlayerID");
        id.SourceVersion = DataRowVersion.Original;

        return cmd;
    }

    private static SqlCommand BuildDeleteCommand(SqlConnection connection)
    {
        var cmd = new SqlCommand(
            "DELETE FROM Player WHERE PlayerID = @PlayerID;",
            connection);

        var id = cmd.Parameters.Add("@PlayerID", SqlDbType.Int, 0, "PlayerID");
        id.SourceVersion = DataRowVersion.Original;

        return cmd;
    }
}
