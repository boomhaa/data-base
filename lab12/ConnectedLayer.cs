using System.Diagnostics;
using Microsoft.Data.SqlClient;

namespace lab12;

public static class ConnectedLayer
{
    public static void Benchmark(string connectionString)
    {
        try
        {
            var newId = InsertPlayer(connectionString,
                nickName: "neo",
                firstName: "Thomas",
                middleName: "",
                lastName: "Anderson",
                birthDate: new DateTime(1990, 1, 1),
                country: "USA",
                rating: 2500);
            
            ReadPlayers(connectionString);
            
            UpdatePlayerRating(connectionString, newId, 2600);
            
            ReadPlayers(connectionString);
            
            DeletePlayer(connectionString, newId);
            
            ReadPlayers(connectionString);
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    private static int InsertPlayer(
        string connectionString,
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
            using var connection = new SqlConnection(connectionString);
            connection.Open();
            
            using var command = new SqlCommand(
                """
                INSERT INTO Player (NickName, FirstName, MiddleName, LastName, BirthDate, Country, Rating)
                OUTPUT INSERTED.PlayerID
                VALUES (@nickName, @firstName, @middleName, @lastName, @birthDate, @country, @rating);
                """,
                connection);

            command.Parameters.AddWithValue("@nickName", nickName);
            command.Parameters.AddWithValue("@firstName", firstName);
            command.Parameters.AddWithValue("@middleName", middleName);
            command.Parameters.AddWithValue("@lastName", lastName);
            command.Parameters.AddWithValue("@birthDate", birthDate);
            command.Parameters.AddWithValue("@country", country);
            command.Parameters.AddWithValue("@rating", rating);

            var newId = (int)command.ExecuteScalar();
            Console.WriteLine($"[Connected] Insert OK. New PlayerID = {newId}");
            return newId;
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return 0;
        }
    }

    private static void ReadPlayers(string connectionString)
    {
        try
        {
            var timer = Stopwatch.StartNew();

            using var connection = new SqlConnection(connectionString);
            connection.Open();

            using var command = new SqlCommand("SELECT * FROM Player;", connection);
            using var reader = command.ExecuteReader();

            Console.WriteLine("-- Data from table Player --");
            Console.WriteLine(
                $"{"NickName",-15}{"FirstName",-15}{"MiddleName",-15}{"LastName",-15}{"BirthDate",-15}{"Country",-15}{"Rating",-10}");
            Console.WriteLine(new string('-', 100));

            while (reader.Read())
            {
                Console.WriteLine(
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
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    private static void UpdatePlayerRating(string connectionString, int playerId, int newRating)
    {
        try
        {
            using var connection = new SqlConnection(connectionString);
            connection.Open();

            using var command =
                new SqlCommand("UPDATE Player SET Rating = @newRating WHERE PlayerID = @id;", connection);

            command.Parameters.AddWithValue("@id", playerId);
            command.Parameters.AddWithValue("@newRating", newRating);

            var rowsAffected = command.ExecuteNonQuery();
            Console.WriteLine(rowsAffected > 0
                ? $"[Connected] Update OK. PlayerID={playerId}, Rating={newRating}"
                : "[Connected] Update: Player not found.");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    private static void DeletePlayer(string connectionString, int playerId)
    {
        try
        {
            using var connection = new SqlConnection(connectionString);
            connection.Open();

            using var command = new SqlCommand("DELETE FROM Player WHERE PlayerID = @id;", connection);
            command.Parameters.AddWithValue("@id", playerId);

            var rowsAffected = command.ExecuteNonQuery();
            Console.WriteLine(rowsAffected > 0
                ? $"[Connected] Delete OK. PlayerID={playerId}"
                : "[Connected] Delete: Player not found.");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }
}
