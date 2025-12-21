using System.Diagnostics;
using Microsoft.Data.SqlClient;

namespace lab12;

public class ConnectedLayer
{
    public static void Init(string connectionString)
    {
        while (true)
        {
            Console.WriteLine("\n-- Choose action --");
            Console.WriteLine("1 - Insert data");
            Console.WriteLine("2 - Read data");
            Console.WriteLine("3 - Update data");
            Console.WriteLine("4 - Delete data");
            Console.WriteLine("5 - Exit");
            Console.Write("\nYour choice: ");
            var choice = int.TryParse(Console.ReadLine(), out var res) ? res : 5;
            switch (choice)
            {
                case 1:
                    InsertData(connectionString);
                    break;
                case 2:
                    ReadData(connectionString);
                    break;
                case 3:
                    UpdateData(connectionString);
                    break;
                case 4:
                    DeleteData(connectionString);
                    break;
                case 5:
                    Console.WriteLine("-- Goodbye! --");
                    return;
                default:
                    Console.WriteLine("There's only 5 options to choose from.");
                    break;
            }
        }
    }

    private static void InsertData(string connectionString)
    {
        using var connection = new SqlConnection(connectionString);

        connection.Open();
        Console.Write("Input player nickname: ");
        var nickName = Console.ReadLine() ?? "";
        Console.Write("Input player first name: ");
        var firstName = Console.ReadLine() ?? "";
        Console.Write("Input player middle name: ");
        var middleName = Console.ReadLine() ?? "";
        Console.Write("Input player middle last name: ");
        var lastName = Console.ReadLine() ?? "";
        Console.Write("Input player birth date in format (yyyy-MM-dd): ");
        var dateOfBirth = DateTime.Parse(Console.ReadLine() ?? "1900-01-01");
        Console.Write("Input player country: ");
        var country = Console.ReadLine() ?? "";
        Console.Write("Input player rating: ");
        var rating = int.Parse(Console.ReadLine() ?? "0");

        using var command = new SqlCommand(
            "INSERT INTO Player (NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating) " +
            "VALUES (@nickName, @firstName, @middleName, @lastName, @birthDate, @country, @rating)",
            connection);

        command.Parameters.AddWithValue("@nickName", nickName);
        command.Parameters.AddWithValue("@firstName", firstName);
        command.Parameters.AddWithValue("@middleName", middleName);
        command.Parameters.AddWithValue("@lastName", lastName);
        command.Parameters.AddWithValue("@birthDate", dateOfBirth);
        command.Parameters.AddWithValue("@country", country);
        command.Parameters.AddWithValue("@rating", rating);
        command.ExecuteNonQuery();
        Console.WriteLine("Player was inserted successfully.");
    }


    private static void ReadData(string connectionString)
    {
        var timer = new Stopwatch();
        timer.Start();

        using var connection = new SqlConnection(connectionString);
        connection.Open();
        using var command = new SqlCommand("SELECT * FROM Player;", connection);
        var reader = command.ExecuteReader();
        Console.WriteLine("-- Data from table Player --");
        Console.WriteLine(
            $"{"PlayerID",-10}{"NickName",-15}{"FirstName",-15}{"MiddleName",-15}{"LastName",-15}{"BirthDate",-15}{"Country",-15}{"Rating",-10}");
        Console.WriteLine(new string('-', 100));
        while (reader.Read())
        {
            Console.WriteLine(
                $"{reader["PlayerID"],-10}" +
                $"{reader["NickName"],-15}" +
                $"{reader["FirstName"],-15}" +
                $"{reader["MiddleName"],-15}" +
                $"{reader["LastName"],-15}" +
                $"{reader["BirthDate"],-15:yyyy-MM-dd}" +
                $"{reader["Country"],-15}" +
                $"{reader["Rating"],-10}");
        }

        timer.Stop();
        Console.WriteLine($"Time to execute (connected layer): {timer.ElapsedMilliseconds} ms");
    }

    private static void UpdateData(string connectionString)
    {
        using var connection = new SqlConnection(connectionString);

        connection.Open();
        Console.Write("Input Player ID for changing: ");
        var id = int.Parse(Console.ReadLine() ?? "0");
        Console.Write("Input new player rating: ");
        var newRating = int.Parse(Console.ReadLine() ?? "0");

        using var command = new SqlCommand("UPDATE Player SET Rating = @newRating WHERE PlayerID = @id", connection);
        command.Parameters.AddWithValue("@id", id);
        command.Parameters.AddWithValue("@newRating", newRating);

        var rowsAffected = command.ExecuteNonQuery();
        Console.WriteLine(
            rowsAffected > 0
                ? "Player was modified successfully."
                : "Player with such an ID was not found."
        );
    }

    private static void DeleteData(string connectionString)
    {
        using var connection = new SqlConnection(connectionString);

        connection.Open();
        Console.Write("Input Player ID for deleting: ");
        var id = int.Parse(Console.ReadLine() ?? "0");

        using var command = new SqlCommand("DELETE FROM Player WHERE PlayerID = @id", connection);
        command.Parameters.AddWithValue("@id", id);

        var rowsAffected = command.ExecuteNonQuery();
        Console.WriteLine(
            rowsAffected > 0
                ? "Player was modified successfully."
                : "Player with such an ID was not found."
        );
    }
}