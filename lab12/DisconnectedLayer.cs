using System.Data;
using Microsoft.Data.SqlClient;

namespace lab12;

public class DisconnectedLayer
{
    private static DataTable? _playerTable;
    private static SqlDataAdapter _adapter;

    public static void Init(string connectionString)
    {
        ReadData(connectionString);

        while (true)
        {
            Console.WriteLine("\n-- Choose action --");
            Console.WriteLine("1 - Insert data into dataset");
            Console.WriteLine("2 - Read data from dataset");
            Console.WriteLine("3 - Update data in dataset");
            Console.WriteLine("4 - Delete data from dataset");
            Console.WriteLine("5 - Load updates to DataBase");
            Console.WriteLine("6 - Exit");
            Console.Write("\nYour choice: ");
            var choice = int.TryParse(Console.ReadLine(), out var res) ? res : 6;
            switch (choice)
            {
                case 1:
                    InsertData();
                    break;
                case 2:
                    ReadData(connectionString);
                    break;
                case 3:
                    UpdateData();
                    break;
                case 4:
                    DeleteData();
                    break;
                case 5:
                    SaveData();
                    break;
                case 6:
                    Console.WriteLine("-- Goodbye! --");
                    return;
                default:
                    Console.WriteLine("There's only 6 options to choose from.");
                    break;
            }
        }
    }

    private static void ReadData(string connectionString)
    {
        if (_playerTable == null)
        {
            _adapter = new SqlDataAdapter("SELECT * FROM Player", connectionString);
            var _ = new SqlCommandBuilder(_adapter);
            _playerTable = new DataTable();
            _adapter.Fill(_playerTable);
            

            _playerTable.PrimaryKey = new[] { _playerTable.Columns["PlayerID"] };
            _playerTable.Columns["PlayerID"].AutoIncrement = true;
            _playerTable.Columns["PlayerID"].AutoIncrementSeed = _playerTable.Rows.Count > 0 ? _playerTable.AsEnumerable().Max(r => (int)r["PlayerID"]) + 1 : 1; 
            _playerTable.Columns["PlayerID"].AutoIncrementStep = 1;
        }
        else
        {
            Console.WriteLine("-- Data from table Player --");
            Console.WriteLine(
                $"{"PlayerID",-10}{"NickName",-15}{"FirstName",-15}{"MiddleName",-15}{"LastName",-15}{"BirthDate",-15}{"Country",-15}{"Rating",-10}");
            Console.WriteLine(new string('-', 100));
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
                    $"{row["Rating"],-10}");
            }
        }
    }

    private static void InsertData()
    {
        Console.Write("Input player nickname: ");
        var nickName = Console.ReadLine() ?? "";
        Console.Write("Input player first name: ");
        var firstName = Console.ReadLine() ?? "";
        Console.Write("Input player middle name: ");
        var middleName = Console.ReadLine() ?? "";
        Console.Write("Input player last last name: ");
        var lastName = Console.ReadLine() ?? "";
        Console.Write("Input player birth date in format (yyyy-MM-dd): ");
        var dateOfBirth = DateTime.Parse(Console.ReadLine() ?? "1900-01-01");
        Console.Write("Input player country: ");
        var country = Console.ReadLine() ?? "";
        Console.Write("Input player rating: ");
        var rating = int.Parse(Console.ReadLine() ?? "0");

        var row = _playerTable.NewRow();
        
        row["NickName"] = nickName;
        row["FirstName"] = firstName;
        row["MiddleName"] = middleName;
        row["LastName"] = lastName;
        row["BirthDate"] = dateOfBirth;
        row["Country"] = country;
        row["Rating"] = rating;

        _playerTable.Rows.Add(row);
        Console.WriteLine("Player was inserted to dataset successfully.");
    }

    private static void UpdateData()
    {
        Console.Write("Input Player ID for changing: ");
        var id = int.Parse(Console.ReadLine() ?? "0");

        var row = _playerTable.Rows.Find(id);
        if (row != null)
        {
            Console.Write("Input new player rating: ");
            var newRating = int.Parse(Console.ReadLine() ?? "0");
            row["Rating"] = newRating;
            Console.WriteLine("Player was modified in dataset successfully.");
        }
        else
        {
            Console.WriteLine("Player with such an ID was not found.");
        }
    }

    private static void DeleteData()
    {
        Console.Write("Input Player ID to delete: ");
        var id = int.Parse(Console.ReadLine() ?? "0");
        var row = _playerTable.Rows.Find(id);

        if (row != null)
        {
            row.Delete();
            Console.WriteLine("Player was deleted from dataset successfully.");
        }
        else
        {
            Console.WriteLine("Player with such an ID was not found.");
        }
    }

    private static void SaveData()
    {
        try
        {
            var updated = _adapter.Update(_playerTable);
            Console.WriteLine($"Updates was saved successfully. Count of update rows: {updated}.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error while saving: {ex.Message}");
        }
    }
}