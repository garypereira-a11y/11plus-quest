export default function AITutorPanel({ data }: any) {
  if (!data) return null;

  return (
    <div className="p-4 bg-white rounded-xl shadow-md">
      
      <h2 className="text-xl font-bold">🦉 Professor Hoot</h2>

      <p className="mt-2">{data.diagnosis}</p>

      <div className="mt-3 p-3 bg-blue-50 rounded">
        <strong>Explanation:</strong>
        <p>{data.explanation}</p>
      </div>

      <div className="mt-3 p-3 bg-yellow-50 rounded">
        <strong>Example:</strong>
        <p>{data.example}</p>
      </div>

      <div className="mt-4">
        <strong>Try this:</strong>
        <p>{data.followUpQuestion.question}</p>
      </div>

      <button className="mt-4 px-4 py-2 bg-green-500 text-white rounded">
        +{data.xpReward} XP Continue
      </button>

    </div>
  );
}